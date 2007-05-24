From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/10] spidernet: skb used after netif_receive_skb
Date: Thu, 24 May 2007 17:25:56 -0400
Message-ID: <465602E4.1050807@garzik.org>
References: <20070522230942.GT5921@austin.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, cbe-oss-dev@ozlabs.org,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	Florin Malita <fmalita@gmail.com>
To: Linas Vepstas <linas@austin.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48101 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752971AbXEXV0C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 May 2007 17:26:02 -0400
In-Reply-To: <20070522230942.GT5921@austin.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Linas Vepstas wrote:
> From: Florin Malita <fmalita@gmail.com>
> 
> The stats update code in spider_net_pass_skb_up() is touching the skb 
> after it's been passed up to the stack. To avoid that, just update the 
> stats first.
> 
> Signed-off-by: Florin Malita <fmalita@gmail.com>
> Signed-off-by: Linas Vepstas <linas@austin.ibm.com>
> ----
> 
>  drivers/net/spider_net.c |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

applied to #upstream-fixes


