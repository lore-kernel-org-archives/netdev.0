From: Jussi Kivilinna <jussi.kivilinna@iki.fi>
Subject: Re: [PATCH 1/2] crypto: add CMAC support to CryptoAPI
Date: Mon, 08 Apr 2013 12:31:24 +0300
Message-ID: <51628E6C.1050600@iki.fi>
References: <20130408074844.6866.90093.stgit@localhost6.localdomain6> <20130408082416.GW21448@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-crypto@vger.kernel.org, netdev@vger.kernel.org,
	Tom St Denis <tstdenis@elliptictech.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-mail-sa-02.sanoma.fi ([158.127.18.162]:37734 "EHLO
	sd-mail-sa-02.sanoma.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933985Ab3DHJb1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Apr 2013 05:31:27 -0400
In-Reply-To: <20130408082416.GW21448@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08.04.2013 11:24, Steffen Klassert wrote:
> On Mon, Apr 08, 2013 at 10:48:44AM +0300, Jussi Kivilinna wrote:
>> Patch adds support for NIST recommended block cipher mode CMAC to CryptoAPI.
>>
>> This work is based on Tom St Denis' earlier patch,
>>  http://marc.info/?l=linux-crypto-vger&m=135877306305466&w=2
>>
>> Cc: Tom St Denis <tstdenis@elliptictech.com>
>> Signed-off-by: Jussi Kivilinna <jussi.kivilinna@iki.fi>
> 
> This patch does not apply clean to the ipsec-next tree
> because of some crypto changes I don't have in ipsec-next.
> The IPsec part should apply to the cryptodev tree,
> so it's probaply the best if we route this patchset
> through the cryptodev tree.

I should have mentioned that the patchset is on top of cryptodev tree and
previous crypto patches that I send yesterday, likely to cause problems
atleast at tcrypt.c:

http://marc.info/?l=linux-crypto-vger&m=136534223503368&w=2

-Jussi

> 
> Herbert,
> 
> are you going to take these patches?
> 
