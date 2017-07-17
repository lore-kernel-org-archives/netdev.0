From: Jean-Louis Dupond <jean-louis@dupond.be>
Subject: Re: Backport - xen-netback: correctly schedule rate-limited queues
Date: Mon, 17 Jul 2017 21:01:33 +0200
Message-ID: <78db386a-aced-e086-e0ab-e7044691d0cb@dupond.be>
References: <a8b4e68ed09513baa788427a0abd11f1@dupond.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from apollo.dupie.be ([62.210.113.39]:60212 "EHLO apollo.dupie.be"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751320AbdGQTBg (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 17 Jul 2017 15:01:36 -0400
Received: from [IPv6:2a02:a03f:10a2:c701:68f7:2084:fdde:efd8] (unknown [IPv6:2a02:a03f:10a2:c701:68f7:2084:fdde:efd8])
        by apollo.dupie.be (Postfix) with ESMTPSA id 88AAE33C00DD
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 21:01:34 +0200 (CEST)
In-Reply-To: <a8b4e68ed09513baa788427a0abd11f1@dupond.be>
Content-Language: en-GB
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Any chance on this? As it gives a possible freeze on all Xen machines 
that use rate-limiting, I really think we should backport this straight 
forward patch.

Thanks
Jean-Louis


Op 11-07-17 om 11:47 schreef Jean-Louis Dupond:
> Hi All,
>
> Is there a chance the following patch 
> (https://git.kernel.org/pub/scm/linux/kernel/git/stable/linux-stable.git/commit/?id=dfa523ae9f2542bee4cddaea37b3be3e157f6e6b) 
> can get backported to the current LTS kernels (including 4.9.x)?
>
> The commit message might not be completely showing the impact of this 
> issue (which is fixed with the patch).
>
> Without the patch, ksoftirqd goes nuts if you upload on a domU with 
> rate-limiting enabled.
> This not only causing high cpu load, but sometimes also a complete 
> hang of the hypervisor.
>
> As the patch is quite important and trivial, I think it would be good 
> to have it backported :)
>
> Thanks
> Jean-Louis
