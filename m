From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3] ip_tunnel: Set network header properly for
 IP_ECN_decapsulate()
Date: Mon, 05 May 2014 16:32:58 -0400 (EDT)
Message-ID: <20140505.163258.2135122265806266709.davem@davemloft.net>
References: <1399242005-28999-1-git-send-email-ycai@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncardwell@google.com,
	sergei.shtylyov@cogentembedded.com
To: ycai@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33443 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754754AbaEEUc7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 May 2014 16:32:59 -0400
In-Reply-To: <1399242005-28999-1-git-send-email-ycai@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Cai <ycai@google.com>
Date: Sun,  4 May 2014 15:20:04 -0700

> In ip_tunnel_rcv(), set skb->network_header to inner IP header
> before IP_ECN_decapsulate().
> 
> Without the fix, IP_ECN_decapsulate() takes outer IP header as
> inner IP header, possibly causing error messages or packet drops.
> 
> Note that this skb_reset_network_header() call was in this spot when
> the original feature for checking consistency of ECN bits through
> tunnels was added in eccc1bb8d4b4 ("tunnel: drop packet if ECN present
> with not-ECT"). It was only removed from this spot in 3d7b46cd20e3
> ("ip_tunnel: push generic protocol handling to ip_tunnel module.").
> 
> Fixes: 3d7b46cd20e3 ("ip_tunnel: push generic protocol handling to ip_tunnel module.")
> Reported-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Ying Cai <ycai@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>

Applied and queued up for -stable, thanks.
