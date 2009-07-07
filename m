From: David Miller <davem@davemloft.net>
Subject: Re: use after free bug in socket code
Date: Mon, 06 Jul 2009 19:07:09 -0700 (PDT)
Message-ID: <20090706.190709.214907244.davem@davemloft.net>
References: <19020.39270.408816.360526@ipc1.ka-ro>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, urs.thuermann@volkswagen.de,
	oliver.hartkopp@volkswagen.de
To: LW@KARO-electronics.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51418
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754113AbZGGCHC convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 6 Jul 2009 22:07:02 -0400
In-Reply-To: <19020.39270.408816.360526@ipc1.ka-ro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Lothar Wa=DFmann <LW@KARO-electronics.de>
Date: Thu, 2 Jul 2009 13:26:30 +0200

> Hi,
>=20
> while developing a canbus driver (with kernel 2.6.30-rc4) I
> encountered a use-after-free bug that led to the following crash (due
> to CONFIG_DEBUG_SLAB being enabled):
 ...
> With the following patch I could alleviate the problem and did not
> find any negative side effects, but I'm not sure, whether this is the
> Right Thing(TM), since I'm not too familiar with the networking code:
 ...
> Any comments on this?

A patch like this shouldn't be needed.

Can one of the CAN folks look into this?
