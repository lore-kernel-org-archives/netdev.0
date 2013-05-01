From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [IPROUTE PATCH v2] iproute2: act_ipt fix xtables breakage on
 older versions.
Date: Wed, 01 May 2013 10:21:07 -0400
Message-ID: <518124D3.8070800@mojatatu.com>
References: <20130429154644.52016.60284.stgit@ahduyck-cp1.jf.intel.com> <517FC04E.30705@mojatatu.com> <517FEC48.80700@intel.com> <51811D06.2070800@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, Hasan Chowdhury <shemonc@gmail.com>,
	Pablo Neira Ayuso <pablo@netfilter.org>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f171.google.com ([209.85.210.171]:41560 "EHLO
	mail-ia0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750933Ab3EAOVJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 May 2013 10:21:09 -0400
Received: by mail-ia0-f171.google.com with SMTP id r13so1396920iar.2
        for <netdev@vger.kernel.org>; Wed, 01 May 2013 07:21:09 -0700 (PDT)
In-Reply-To: <51811D06.2070800@mojatatu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 13-05-01 09:47 AM, Jamal Hadi Salim wrote:
> Hi Alex,
>

> So now i am wondering how the FSCK this thing even compiled.

Mystery solved. Man, this idea of keeping up with the distros and
iptables variants is a little insane.
Debian's setup ends up using m_ipt.c for anything less than iptable
1.4.11. Kudos to the debian iproute maintainer.
Fedora on the other hand seems to going to m_xt.c
(This is why i asked for your Config earlier).
In any case, your patch is correct. So i will go sign off on it;
its just nobody else had to deal with that (or reported it).

Thanks for your patience Alex.

cheers,
jamal
