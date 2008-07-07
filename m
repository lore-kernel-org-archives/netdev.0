From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] ipv[46]: Fix MD5 signatures for non-linear skbs
Date: Mon, 7 Jul 2008 11:22:37 -0700
Message-ID: <20080707112237.14fb3284@extreme>
References: <396556a20807071021n2039fc8eo6ab343355e36b468@mail.gmail.com>
	<396556a20805301217k293e5718h6bbf02bfe069001@europa>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: "Adam Langley" <agl@imperialviolet.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:38796 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754144AbYGGSWo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 7 Jul 2008 14:22:44 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069001@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 7 Jul 2008 10:22:43 -0700
"Adam Langley" <agl@imperialviolet.org> wrote:

> ipv[46]: Fix MD5 signatures for non-linear skbs
> 
> Currently, the MD5 code assumes that the SKBs are linear and, in the case
> that they aren't, happily goes off and hashes off the end of the SKB and
> into random memory.
> 
> Reported by Stephen Hemminger in [1]. Advice thanks to Stephen and Evgeniy
> Polyakov. Also includes a couple of missed route_caps from Stephen's patch
> in [2].
> 
> [1] http://marc.info/?l=linux-netdev&m=121445989106145&w=2
> [2] http://marc.info/?l=linux-netdev&m=121459157816964&w=2
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Patch doesn't apply cleanly to net-next-2.6 tree because of other changes
so to help the merge, please create a version for that as well.
