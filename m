From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] IPv6: fix CoA check in RH2 input handler
 (mip6_rthdr_input())
Date: Sun, 18 Jul 2010 15:05:03 -0700 (PDT)
Message-ID: <20100718.150503.267945037.davem@davemloft.net>
References: <87aapr7lu3.fsf@small.ssi.corp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, netdev@vger.kernel.org
To: arno@natisbad.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37790
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757367Ab0GRWEr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jul 2010 18:04:47 -0400
In-Reply-To: <87aapr7lu3.fsf@small.ssi.corp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: arno@natisbad.org (Arnaud Ebalard)
Date: Fri, 16 Jul 2010 12:38:44 +0200

> The input handler for Type 2 Routing Header (mip6_rthdr_input())
> checks if the CoA in the packet matches the CoA in the XFRM state.
> 
> Current check is buggy: it compares the adddress in the Type 2
> Routing Header, i.e. the HoA, against the expected CoA in the state.
> The comparison should be made against the address in the destination
> field of the IPv6 header.
> 
> The bug remained unnoticed because the main (and possibly only current)
> user of the code (UMIP MIPv6 Daemon) initializes the XFRM state with the
> unspecified address, i.e. explicitly allows everything.
> 
> Yoshifuji-san, can you ack that one?
> 
> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>

I've reviewed this and it definitely looks correct to me.

Applied, thanks Arnaud.
