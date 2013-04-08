From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 1/2] crypto: add CMAC support to CryptoAPI
Date: Mon, 8 Apr 2013 10:24:16 +0200
Message-ID: <20130408082416.GW21448@secunet.com>
References: <20130408074844.6866.90093.stgit@localhost6.localdomain6>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Tom St Denis <tstdenis@elliptictech.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:56820 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934445Ab3DHIYU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Apr 2013 04:24:20 -0400
Content-Disposition: inline
In-Reply-To: <20130408074844.6866.90093.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 08, 2013 at 10:48:44AM +0300, Jussi Kivilinna wrote:
> Patch adds support for NIST recommended block cipher mode CMAC to CryptoAPI.
> 
> This work is based on Tom St Denis' earlier patch,
>  http://marc.info/?l=linux-crypto-vger&m=135877306305466&w=2
> 
> Cc: Tom St Denis <tstdenis@elliptictech.com>
> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>

This patch does not apply clean to the ipsec-next tree
because of some crypto changes I don't have in ipsec-next.
The IPsec part should apply to the cryptodev tree,
so it's probaply the best if we route this patchset
through the cryptodev tree.

Herbert,

are you going to take these patches?
