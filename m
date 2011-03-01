From: David Miller <davem@davemloft.net>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 01 Mar 2011 12:36:54 -0800 (PST)
Message-ID: <20110301.123654.115931472.davem@davemloft.net>
References: <20110228113659.GA20726@gondor.apana.org.au>
	<20110301123519.GA7453@gondor.apana.org.au>
	<1298997787.3284.123.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: herbert@gondor.apana.org.au, rick.jones2@hp.com,
	therbert@google.com, wsommerfeld@google.com,
	daniel.baluta@gmail.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35397
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757148Ab1CAUgR convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 15:36:17 -0500
In-Reply-To: <1298997787.3284.123.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 01 Mar 2011 17:43:07 +0100

> Le mardi 01 mars 2011 =E0 20:35 +0800, Herbert Xu a =E9crit :
>> On Mon, Feb 28, 2011 at 07:36:59PM +0800, Herbert Xu wrote:
>> > Here are the patches I used.  Please don't them yet as I intend
>> > to clean them up quite a bit.
>>=20
>> OK here is the version ready for merging (please retest them
>> though as I have changed things substantially).
>>=20
>> The main change is that the legacy UDP code path is now gone
>> so we use the same UDP header generation whether corking is on
>> or off.
>>=20
>> I will add IPv6 support in a later patch set.
>>=20
>> Thanks!
>=20
> For the whole patchset :
>=20
> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Applied, great work everyone!
