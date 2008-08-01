From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] MD5: Fix MD5 signatures on certain ACK packets
Date: Thu, 31 Jul 2008 20:50:39 -0700 (PDT)
Message-ID: <20080731.205039.95463450.davem@davemloft.net>
References: <396556a20805301217k293e5718h6bbf02bfe069050@europa>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: agl@imperialviolet.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36223
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752152AbYHADuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Jul 2008 23:50:39 -0400
In-Reply-To: <396556a20805301217k293e5718h6bbf02bfe069050@europa>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Adam Langley" <agl@imperialviolet.org>
Date: Thu, 31 Jul 2008 19:56:31 -0700

> I noticed, looking at tcpdumps, that timewait ACKs were getting sent with an
> incorrect MD5 signature when signatures were enabled.
> 
> I broke this in 49a72dfb8814c2d65bd9f8c9c6daf6395a1ec58d. I didn't take into
> account that the skb passed to tcp_*_send_ack was the inbound packet, thus the
> source and dest addresses need to be swapped when calculating the MD5
> pseudoheader.
> 
> Signed-off-by: Adam Langley <agl@imperialviolet.org>

Applied.

But please provide commit header line text when referencing SHA IDs.
Here is the final fixed up commit message I used when applying this.

    tcp: MD5: Fix MD5 signatures on certain ACK packets
    
    I noticed, looking at tcpdumps, that timewait ACKs were getting sent
    with an incorrect MD5 signature when signatures were enabled.
    
    I broke this in 49a72dfb8814c2d65bd9f8c9c6daf6395a1ec58d ("tcp: Fix
    MD5 signatures for non-linear skbs"). I didn't take into account that
    the skb passed to tcp_*_send_ack was the inbound packet, thus the
    source and dest addresses need to be swapped when calculating the MD5
    pseudoheader.
    
    Signed-off-by: Adam Langley <agl@imperialviolet.org>
