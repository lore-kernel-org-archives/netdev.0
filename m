From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv4+ipv6: Make INET*_ESP select CRYPTO_ECHAINIV
Date: Mon, 25 Jan 2016 10:46:14 -0800 (PST)
Message-ID: <20160125.104614.1095945891181570299.davem@davemloft.net>
References: <20160125102659.GA6976@gondor.apana.org.au>
	<56A60DF4.30700@gmx.de>
	<20160125135628.GA8256@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hakke_007@gmx.de, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49023 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757417AbcAYSqP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Jan 2016 13:46:15 -0500
In-Reply-To: <20160125135628.GA8256@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Mon, 25 Jan 2016 21:56:28 +0800

> On Mon, Jan 25, 2016 at 12:58:44PM +0100, Thomas Egerer wrote:
>> The ESP algorithms using CBC mode require echainiv. Hence INET*_ESP have
>> to select CRYPTO_ECHAINIV in order to work properly. This solves the
>> issues caused by a misconfiguration as described in [1].
>> The original approach, patching crypto/Kconfig was turned down by
>> Herbert Xu [2].
>> 
>> [1] https://lists.strongswan.org/pipermail/users/2015-December/009074.html
>> [2] http://marc.info/?l=linux-crypto-vger&m=145224655809562&w=2
>> 
>> Signed-off-by: Thomas Egerer <hakke_007@gmx.de>
> 
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks.
