From: Greg Ungerer <gerg@snapgear.com>
Subject: Re: [PATCH] fec: fix definition of 5272 version of FEC_X_DES_ACTIVE
 register
Date: Tue, 07 Jul 2009 11:37:18 +1000
Message-ID: <4A52A6CE.6010509@snapgear.com>
References: <200907070123.n671NY36005818@localhost.localdomain> <20090706.182704.192109619.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, gerg@uclinux.org, s.hauer@pengutronix.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rex.securecomputing.com ([203.24.151.4]:44382 "EHLO
	cyberguard.com.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753313AbZGGBhR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jul 2009 21:37:17 -0400
In-Reply-To: <20090706.182704.192109619.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

David Miller wrote:
> From: Greg Ungerer <gerg@snapgear.com>
> Date: Tue, 7 Jul 2009 11:23:34 +1000
>=20
>> fec: fix definition of 5272 version of FEC_X_DES_ACTIVE register
>>
>> The ColdFire 5272 FEC driver has a different register address map
>> than other users of the FEC driver. And its definition of the
>> FEC_X_DES_ACTIVE register is incorrect, it should be 0x14.
>> The fec interface cannot transmit data with the old value.
>>
>> Signed-off-by: Greg Ungerer <gerg@uclinux.org>
>=20
> This wasn't handled well at all.
>=20
> You sent me what amounted to a cleanup patch to remove the
> trailing ";" in these definitions first.  I can only put
> that into net-next-2.6

That is not a cleanup patch. It is a bug fix. You cannot build
with those ";" in there:

   CC      drivers/net/fec.o
In file included from drivers/net/fec.c:51:
drivers/net/fec.h:49:19: warning: missing whitespace after the macro na=
me
drivers/net/fec.h:50:19: warning: missing whitespace after the macro na=
me
drivers/net/fec.h:51:18: warning: missing whitespace after the macro na=
me
drivers/net/fec.h:52:17: warning: missing whitespace after the macro na=
me
drivers/net/fec.h:53:25: warning: missing whitespace after the macro na=
me
drivers/net/fec.h:54:25: warning: missing whitespace after the macro na=
me
drivers/net/fec.c: In function =91fec_enet_start_xmit=92:
drivers/net/fec.c:352: error: expected expression before =91;=92 token
drivers/net/fec.c: In function =91fec_enet_interrupt=92:


> Now you send me a real bug fix for one of these macro
> values and it only applies on top of that ";" removal
> patch.
 >
> That completely sucks.  Now I can't just apply this to
> net-2.6 to get the bug fixed.
>=20
> You should have sent just the bug fix, then waited a week
> or so for the net-2.6 tree to get merged into the net-next-2.6
> tree and then you could send the ";" cleanup cleanly on top
> of that.
>=20
> I can't apply this so I'm rejecting it in patchwork.

Care to reconsider?

Regards
Greg


-----------------------------------------------------------------------=
-
Greg Ungerer  --  Principal Engineer        EMAIL:     gerg@snapgear.co=
m
SnapGear Group, McAfee                      PHONE:       +61 7 3435 288=
8
825 Stanley St,                             FAX:         +61 7 3891 363=
0
Woolloongabba, QLD, 4102, Australia         WEB: http://www.SnapGear.co=
m
