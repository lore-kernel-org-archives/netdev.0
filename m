From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: VJ Channel API - driver level (PATCH)
Date: Thu, 04 May 2006 03:45:08 +0900 (JST)
Message-ID: <20060504.034508.23027240.yoshfuji@linux-ipv6.org>
References: <54AD0F12E08D1541B826BE97C98F99F149E880@NT-SJCA-0751.brcm.ad.broadcom.com>
	<20060503180740.GA14506@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johnpol@2ka.mipt.ru, caitlinb@broadcom.com,
	Leonid.Grossman@neterion.com, davem@davemloft.net,
	shemminger@osdl.org, alex@neterion.com, yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:18181 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1750724AbWECSpC
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 May 2006 14:45:02 -0400
To: netdev@vger.kernel.org
In-Reply-To: <20060503180740.GA14506@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060503180740.GA14506@2ka.mipt.ru> (at Wed, 3 May 2006 22:07:40 +0400), Evgeniy Polyakov <johnpol@2ka.mipt.ru> says:

> > Even if the hardware cannot fully implement netfilter rules
> > there is still value in having an interface that documents 
> > exactly how much filtering a given piece of hardware can do.
> > There is no point in having the kernel repeat packet classifications
> > that have already been done by the NIC.
> 
> Please do not suppose that vj channel must rely on underlaying hardware.
> New interface MUST work better or at least not worse than existing skb
> queueing for majority of users, and I doubt users with netfilter capable
> hardware are there.
> It is only some hint to the SW, not rules, that hardware can provide.
> The best would be ipv4/ipv6 hashing, and I think it is enough.

And, I believe that, if a packet contains any ipv6 extension header(s),
including routing header, fragmentation header, etc., 
we should process it in kernel as we do for now.

Regards,

--yoshfuji
