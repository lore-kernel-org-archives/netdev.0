From: David Miller <davem@davemloft.net>
Subject: Re: [Resend v2 PATCH 1/3] TCP: Fix MD5 signatures for non-linear
 skbs
Date: Sat, 19 Jul 2008 00:03:29 -0700 (PDT)
Message-ID: <20080719.000329.174382280.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069021@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60541
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751406AbYGSHDa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 03:03:30 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069021@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Thu, 17 Jul 2008 16:08:10 -0700

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
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Adam.
