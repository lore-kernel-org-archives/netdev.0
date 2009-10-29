From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH 1/4] gro: Name the GRO result enumeration type
Date: Thu, 29 Oct 2009 18:14:21 +0000
Message-ID: <1256840061.2827.80.camel@achroite>
References: <1256836629.2827.69.camel@achroite>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>, netdev@vger.kernel.org,
	linux-net-drivers@solarflare.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:44736 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754369AbZJ2SOU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 14:14:20 -0400
In-Reply-To: <1256836629.2827.69.camel@achroite>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2009-10-29 at 17:17 +0000, Ben Hutchings wrote:
> This clarifies which return and parameter types are GRO result codes
> and not RX result codes.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>

Sorry, this adds some warnings about unhandled enumeration values in a
couple of switch statements.  I built this with C=2 and mistook the gcc
warnings for sparse warnings, which I chose to ignore since the
unhandled values are clearly harmless.

I suppose I should add an explicit 'default:' to the switches at the
same time.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

