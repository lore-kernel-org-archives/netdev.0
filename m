From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] act_nat: not all of the ICMP packets need an IP header
	payload
Date: Sat, 10 Jul 2010 14:26:23 +0800
Message-ID: <20100710062623.GA4907@gondor.apana.org.au>
References: <1278725605-28598-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Rodrigo Partearroyo =?iso-8859-1?Q?Gonz=E1lez?=
	<rpartearroyo@albentia.com>, Eric Dumazet <eric.dumazet@gmail.com>,
	Iratxo Pichel Ortiz <ipichel@albentia.com>,
	Noelia =?iso-8859-1?Q?Mor=F3n?= <nmoron@albentia.com>,
	netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helcar.apana.org.au ([209.40.204.226]:40484 "EHLO
	fornost.hengli.com.au" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751178Ab0GJG0f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jul 2010 02:26:35 -0400
Content-Disposition: inline
In-Reply-To: <1278725605-28598-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jul 10, 2010 at 09:33:25AM +0800, Changli Gao wrote:
> act_nat: not all of the ICMP packets need an IP header payload
> 
> not all of the ICMP packets need an IP header payload, so we check the length
> of the skbs only when the packets should have an IP header payload.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Thanks!
-- 
Email: Herbert Xu <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
