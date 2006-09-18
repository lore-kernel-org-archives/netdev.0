From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.18-rc6 memory mapped pcap truncates outgoing TCP packets,
 but not icmp
Date: Mon, 18 Sep 2006 00:00:14 -0700 (PDT)
Message-ID: <20060918.000014.07640227.davem@davemloft.net>
References: <450928B2.4090003@trash.net>
	<20060915120235.GA9833@outpost.ds9a.nl>
	<450B0A11.2050608@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bert.hubert@netherlabs.nl, cpw@lanl.gov, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40582
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S965505AbWIRHAQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:00:16 -0400
To: kaber@trash.net
In-Reply-To: <450B0A11.2050608@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Fri, 15 Sep 2006 22:16:17 +0200

> bert hubert wrote:
> >>It appears to be intentionally, but I don't see a reason for it.
> >>Can you try if this patch makes it work as expected?
> > 
> > 
> >>[PACKET]: Don't truncate non-linear skbs with mmaped IO
> >>
> >>Non-linear skbs are truncated to their linear part with mmaped IO.
> >>Fix by using skb_copy_bits instead of memcpy.
> > 
> > 
> > Works very well for me! I hope this can make it into 2.6.18.
> 
> 
> That would be fine with me, lets see what Dave thinks.

Applied to net-2.6, thanks a lot.
