From: Victor Julien <victor@inliniac.net>
Subject: Re: [PATCH 2/2] packet: Add fanout support.
Date: Tue, 05 Jul 2011 09:06:13 +0200
Message-ID: <4E12B7E5.1060408@inliniac.net>
References: <20110704.212014.236340473910292460.davem@davemloft.net>  <1309846875.2720.43.camel@edumazet-laptop>  <4E12B5A6.2020802@inliniac.net> <1309849214.2720.45.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-27.netfusion.at ([83.215.238.27]:40730 "EHLO
	tulpe.vuurmuur.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753815Ab1GEHGi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jul 2011 03:06:38 -0400
In-Reply-To: <1309849214.2720.45.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/05/2011 09:00 AM, Eric Dumazet wrote:
> Le mardi 05 juillet 2011 =C3=A0 08:56 +0200, Victor Julien a =C3=A9cr=
it :
>=20
>> Is this still also true for IP fragments?
>>
>=20
> This point was already raised. IP fragments have rxhash =3D 0, obviou=
sly,
> since we dont have full information (source / destination ports for
> example)

Sure, just seeing if something was changed here as that wasn't
immediately obvious to me from the code.

--=20
---------------------------------------------
Victor Julien
http://www.inliniac.net/
PGP: http://www.inliniac.net/victorjulien.asc
---------------------------------------------

