From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_gre: include route header_len in max_headroom
 calculation
Date: Sun, 21 Mar 2010 21:26:28 -0700 (PDT)
Message-ID: <20100321.212628.267964108.davem@davemloft.net>
References: <4BA4C2ED.9090701@iki.fi>
	<4BA4E000.1030206@iki.fi>
	<20100320150049.GA2950@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37734
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750877Ab0CVE0I convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 00:26:08 -0400
In-Reply-To: <20100320150049.GA2950@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 20 Mar 2010 23:00:49 +0800

> On Sat, Mar 20, 2010 at 04:47:28PM +0200, Timo Ter=E4s wrote:
>>
>> Actually, isn't the above right?
>>
>> max_headroom is calculated with LL_RESERVED_SPACE of the tdev, which
>> is the interface to which the gre packet is being sent to, not the
>> gre interface. Thus, max_headroom won't include gre devices
>> previous needed_headroom.
>=20
> Indeed you're right.  Sorry for the confusion.
>=20
> Acked-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied, thanks everyone.
