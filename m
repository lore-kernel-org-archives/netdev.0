From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 7/8] ethtool: Add GGRO and SGRO ops
Date: Fri, 12 Dec 2008 20:11:17 +0000
Message-ID: <1229112677.3051.9.camel@achroite>
References: <20081212053116.GA2927@gondor.apana.org.au>
	 <E1LB0d2-0000rq-Dr@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:36107 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752123AbYLLULX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 15:11:23 -0500
In-Reply-To: <E1LB0d2-0000rq-Dr@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-12-12 at 16:31 +1100, Herbert Xu wrote:
> ethtool: Add GGRO and SGRO ops
> 
> This patch adds the ethtool ops to enable and disable GRO.  It also
> makes GRO depend on RX checksum offload much the same as how TSO
> depends on SG support.
[...]

Why don't you add NETIF_F_GRO to the flags handled by get_flags() and
set_flags()?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

