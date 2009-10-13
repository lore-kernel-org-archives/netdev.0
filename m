From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Re: PACKET_TX_RING: packet size is too long
Date: Tue, 13 Oct 2009 00:54:38 -0700 (PDT)
Message-ID: <20091013.005438.32630424.davem@davemloft.net>
References: <20091009090711.GG23133@boogie.lpds.sztaki.hu>
	<20091009220546.GB7618@boogie.lpds.sztaki.hu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, johann.baudy@gnu-log.net
To: gombasg@sztaki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38578
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753688AbZJMHyl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Oct 2009 03:54:41 -0400
In-Reply-To: <20091009220546.GB7618@boogie.lpds.sztaki.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Gabor Gombas <gombasg@sztaki.hu>
Date: Sat, 10 Oct 2009 00:05:46 +0200

> Hi,
> 
> Digging list archives I suspect the current value of size_max is the
> remnant of the zero-copy mode that was not merged. So I propose the
> following patch that IMHO makes the value of size_max consistent with
> how the frame is actually handled in tpacket_fill_skb().
> 
> If the zero-copy mode is ever to be resurrected, then the user should
> explicitely request it, and either the length of the extra padding
> should be the same for 32-bit and 64-bit kernels or there must be a way
> to query the value at run time.

Johann, please take a look at this.

Gabor, please resubmit your patch with a proper Signed-off-by:
tag so I can apply it if it is correct.

Thanks.
