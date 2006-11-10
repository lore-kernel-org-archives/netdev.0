From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [TCP]: remove dead code in init_sequence
Date: Fri, 10 Nov 2006 14:07:02 -0800 (PST)
Message-ID: <20061110.140702.97293507.davem@davemloft.net>
References: <200611101204.31644@strip-the-willow>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:30657
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S966122AbWKJWHB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 10 Nov 2006 17:07:01 -0500
To: gerrit@erg.abdn.ac.uk
In-Reply-To: <200611101204.31644@strip-the-willow>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Date: Fri, 10 Nov 2006 12:04:31 +0000

> This removes two redundancies:
> 
> 1) The test (skb->protocol == htons(ETH_P_IPV6) in tcp_v6_init_sequence()
>    is always true, due to
> 	* tcp_v6_conn_request() is the only function calling this one
> 	* tcp_v6_conn_request() redirects all skb's with ETH_P_IP protocol to
> 	  tcp_v4_conn_request() [ cf. top of tcp_v6_conn_request()]
> 
> 2) The first argument, `struct sock *sk' of tcp_v{4,6}_init_sequence() is 
>    never used.
> 
> Patch has been tested.
> 
> 
> Signed-off-by: Gerrit Renker  <gerrit@erg.abdn.ac.uk>

Looks good, patch applied, thanks Gerrit.
