From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 7/8] ethtool: Add GGRO and SGRO ops
Date: Fri, 12 Dec 2008 22:35:27 +0000
Message-ID: <1229121327.3051.69.camel@achroite>
References: <20081212053116.GA2927@gondor.apana.org.au>
	 <E1LB0d2-0000rq-Dr@gondolin.me.apana.org.au>
	 <1229112677.3051.9.camel@achroite>
	 <20081212214835.GD11046@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost02.mail.zen.net.uk ([212.23.3.141]:34695 "EHLO
	smarthost02.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753246AbYLLWfc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Dec 2008 17:35:32 -0500
In-Reply-To: <20081212214835.GD11046@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2008-12-13 at 08:48 +1100, Herbert Xu wrote:
> On Fri, Dec 12, 2008 at 08:11:17PM +0000, Ben Hutchings wrote:
> > On Fri, 2008-12-12 at 16:31 +1100, Herbert Xu wrote:
> > > ethtool: Add GGRO and SGRO ops
> > > 
> > > This patch adds the ethtool ops to enable and disable GRO.  It also
> > > makes GRO depend on RX checksum offload much the same as how TSO
> > > depends on SG support.
> > [...]
> > 
> > Why don't you add NETIF_F_GRO to the flags handled by get_flags() and
> > set_flags()?
> 
> Surely the patch itself has answered this :) It's because of the
> dependency on RX checksum offload.  We want GRO to be off unless
> RX checksum offload is on.

If I'm not mistaken, the whole point of set_flags() is to end the
continued expansion of struct ethtool_ops by another 2 functions for
every new offload feature.  The comments make it fairly clear that Jeff
anticipated that it might be necessary to include such checks for some
flags.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

