From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] tcp: return sizeof tcp_dctcp_info in
 dctcp_get_info()
Date: Tue, 14 Jun 2016 23:46:41 -0700 (PDT)
Message-ID: <20160614.234641.244436885110824251.davem@davemloft.net>
References: <1465831235-29876-1-git-send-email-ncardwell@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, soheil@google.com, edumazet@google.com
To: ncardwell@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751400AbcFOGqm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 02:46:42 -0400
In-Reply-To: <1465831235-29876-1-git-send-email-ncardwell@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Neal Cardwell <ncardwell@google.com>
Date: Mon, 13 Jun 2016 11:20:35 -0400

> Make sure that dctcp_get_info() returns only the size of the
> info->dctcp struct that it zeroes out and fills in. Previously it had
> been returning the size of the enclosing tcp_cc_info union,
> sizeof(*info).  There is no problem yet, but that union that may one
> day be larger than struct tcp_dctcp_info, in which case the
> TCP_CC_INFO code might accidentally copy uninitialized bytes from the
> stack.
> 
> Signed-off-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
