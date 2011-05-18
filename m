From: David Miller <davem@davemloft.net>
Subject: Re: small RPS cache for fragments?
Date: Wed, 18 May 2011 02:37:59 -0400 (EDT)
Message-ID: <20110518.023759.624266793051870646.davem@davemloft.net>
References: <BANLkTikyH=q_6uOvFh3_Z_xwPST3zVijZw@mail.gmail.com>
	<20110517.164929.1737248436066795381.davem@davemloft.net>
	<BANLkTimmvKn2e5Yrkd5TtktyxTWCRxqinw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: therbert@google.com, netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:45836 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753982Ab1ERGiE convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 May 2011 02:38:04 -0400
In-Reply-To: <BANLkTimmvKn2e5Yrkd5TtktyxTWCRxqinw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 18 May 2011 07:59:05 +0800

> On Wed, May 18, 2011 at 4:49 AM, David Miller <davem@davemloft.net> w=
rote:
>>
>> Actually, I think it won't work. =A0Even Linux emits fragments last =
to
>> first, so we won't see the UDP header until the last packet where it=
's
>> no longer useful.
>>
>=20
> No. Linux emits fragments first to last now. You should check the
> current code. :)

I forgot that we rearranged this, thanks :-)

So maybe the original idea can indeed work.
