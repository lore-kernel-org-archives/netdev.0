From: Jiri Benc <jbenc@redhat.com>
Subject: Re: [PATCH net-next v2 4/7] vxlan: improve vxlan route lookup
 checks.
Date: Thu, 10 Nov 2016 19:37:09 +0100
Message-ID: <20161110193709.2c539093@griffin>
References: <1478371557-71888-1-git-send-email-pshelar@ovn.org>
        <1478371557-71888-5-git-send-email-pshelar@ovn.org>
        <20161109174138.410b4385@griffin>
        <CAOrHB_BwcJ0K3YcqPrVkKxFjWX9DFT1NjS3BbrcNtKQ_p_y44w@mail.gmail.com>
        <20161110105639.6e8b70f7@griffin>
        <CAOrHB_DPWiGah9vADm=SXXnWkiDcvsHdmy3RQ6f7ntjmjZOeDg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51462 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751674AbcKJShM (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 10 Nov 2016 13:37:12 -0500
In-Reply-To: <CAOrHB_DPWiGah9vADm=SXXnWkiDcvsHdmy3RQ6f7ntjmjZOeDg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 10 Nov 2016 10:10:25 -0800, Pravin Shelar wrote:
> I am specifically talking about cached routes. If the dst entry is
> cached, this patch avoids checking for device loop.

Okay, true, for cached routes we do less work with this patch.

This was more a side note anyway, the real comment was increasing of
the dev stats (which you already said you would fix).

Thanks!

 Jiri
