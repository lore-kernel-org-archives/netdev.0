From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] macvlan: fix leak in macvlan_handle_frame
Date: Tue, 17 Nov 2015 14:40:14 -0500 (EST)
Message-ID: <20151117.144014.402280202991903863.davem@davemloft.net>
References: <d4141a7c4841ae5f631858a8537968419f0e396b.1447705984.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us, kaber@trash.net
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58153 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932085AbbKQTkR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2015 14:40:17 -0500
In-Reply-To: <d4141a7c4841ae5f631858a8537968419f0e396b.1447705984.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Mon, 16 Nov 2015 22:54:20 +0100

> Reset pskb in macvlan_handle_frame in case skb_share_check returned a
> clone.
> 
> Fixes: 8a4eb5734e8d ("net: introduce rx_handler results and logic around that")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Applied.
