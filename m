From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: [PATCH net-next] bnx2: switch to build_skb() infrastructure
Date: Thu, 17 Nov 2011 20:47:24 -0800
Message-ID: <1321591644.8833.1.camel@HP1>
References: <1321378205.2856.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms2.broadcom.com ([216.31.210.18]:2003 "EHLO mms2.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756552Ab1KRE6c (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Nov 2011 23:58:32 -0500
In-Reply-To: <1321378205.2856.24.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Tue, 2011-11-15 at 09:30 -0800, Eric Dumazet wrote:
> This is very similar to bnx2x conversion, but bnx2 only requires 16bytes
> alignement at start of the received frame to store its l2_fhdr, so goal
> was not to reduce skb truesize (in fact it should not change after this
> patch)
> 
> Using build_skb() reduces cache line misses in the driver, since we
> use cache hot skb instead of cold ones. Number of in-flight sk_buff
> structures is lower, they are more likely recycled in SLUB caches
> while still hot.
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Michael Chan <mchan@broadcom.com>
> CC: Eilon Greenstein <eilong@broadcom.com>

Looks good.  Thanks.

Reviewed-by: Michael Chan <mchan@broadcom.com>
