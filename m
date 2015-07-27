From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipv4: be more aggressive when probing
 alternative gateways
Date: Sun, 26 Jul 2015 20:57:09 -0700 (PDT)
Message-ID: <20150726.205709.1672032868703212076.davem@davemloft.net>
References: <1437637175-8052-1-git-send-email-ja@ssi.bg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fw@strlen.de
To: ja@ssi.bg
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37824 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755141AbbG0D5K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 26 Jul 2015 23:57:10 -0400
In-Reply-To: <1437637175-8052-1-git-send-email-ja@ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>
Date: Thu, 23 Jul 2015 10:39:35 +0300

> Currently, we do not notice if new alternative gateways
> are added. We can do it by checking for present neigh
> entry. Also, gateways that are currently probed (NUD_INCOMPLETE)
> can be skipped from round-robin probing.
> 
> Suggested-by: Florian Westphal <fw@strlen.de>
> Signed-off-by: Julian Anastasov <ja@ssi.bg>

Applied.
