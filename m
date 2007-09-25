From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 5/7] CAN: Add virtual CAN netdevice driver
Date: Tue, 25 Sep 2007 16:47:00 +0200
Message-ID: <46F91F64.2050008@trash.net>
References: <20070925122029.15989.0@janus.isnogud.escape.de>	<20070925122244.15989.5@janus.isnogud.escape.de>	<20070925.222631.116063075.yoshfuji@linux-ipv6.org> <ygfir5yetfp.fsf@janus.isnogud.escape.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-15?Q?YOSHIFUJI_Hideaki_/_=C8=A3=D1=C0?=
	<yoshfuji@linux-ipv6.org>, netdev@vger.kernel.org,
	davem@davemloft.net, joe@perches.com, tglx@linutronix.de,
	oliver@hartkopp.net, oliver.hartkopp@volkswagen.de
To: Urs Thuermann <urs@isnogud.escape.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36798 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751554AbXIYO4a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 10:56:30 -0400
In-Reply-To: <ygfir5yetfp.fsf@janus.isnogud.escape.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Urs Thuermann wrote:
> YOSHIFUJI Hideaki / =C8=A3=D1=C0  <yoshfuji@linux-ipv6.org> writes:
>=20
>=20
>>I'm not a lawyer, but the following lines:
>>
>>| + * Alternatively, provided that this notice is retained in full, t=
his
>>                     ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
>>| + * software may be distributed under the terms of the GNU General
>>| + * Public License ("GPL") version 2 as distributed in the 'COPYING=
'
>>| + * file from the main directory of the linux kernel source.
>>
>>make this whole licence imcompatible with GPL.
>=20
>=20
> I'm no lawyer at all, either.  And also Oliver is not, but he has
> carried out the fights with our company lawyers.  Maybe he can say
> something about whether we can change this.
>=20
>=20
>>I do think you need to allow people to select GPLv2 only.
>=20
>=20
> The sentence you cite *does* allow distribution under GPLv2 only.  An=
d
> I think I have often read the restriction to retain such licences in
> full in GPLv2 code.  Is that really incompatible?


Not that it necessarily means its valid, but there are multiple
files in the kernel that carry the exact same term:

arch/x86_64/crypto/aes.c
arch/i386/crypto/aes.c
crypto/gf128mul.c
crypto/aes.c
drivers/net/ppp_mppe.c
drivers/crypto/padlock-aes.c
include/crypto/b128ops.h
include/crypto/gf128mul.h

OTOH I tend to agree with Yoshifuji that once someone has
selected the GPL and has made enough changes that no parts
"can be reasonably considered independent and separate works",
it seems like an additional and confusing restriction to be
forced to retain ineffective licensing terms.

But since I'm not a lawyer either I'm going to refrain from
further speculation :)
