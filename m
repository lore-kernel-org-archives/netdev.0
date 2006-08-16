From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2]: powerpc/cell spidernet bottom half
Date: Wed, 16 Aug 2006 15:29:19 -0700 (PDT)
Message-ID: <20060816.152919.88472383.davem@davemloft.net>
References: <200608162324.47235.arnd@arndb.de>
	<20060816.143203.11626235.davem@davemloft.net>
	<200608170016.47072.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linuxppc-dev@ozlabs.org, akpm@osdl.org, jeff@garzik.org,
	netdev@vger.kernel.org, jklewis@us.ibm.com,
	linux-kernel@vger.kernel.org, Jens.Osterkamp@de.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:57758
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932298AbWHPWaD convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2006 18:30:03 -0400
To: arnd@arndb.de
In-Reply-To: <200608170016.47072.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Arnd Bergmann <arnd@arndb.de>
Date: Thu, 17 Aug 2006 00:16:46 +0200

> Am Wednesday 16 August 2006 23:32 schrieb David Miller:
> > Can spidernet be told these kinds of parameters? =A0"N packets or
> > X usecs"?
>=20
> It can not do exactly this but probably we can get close to it by

Oh, you can only control TX packet counts using bits in the TX ring
entries :(

Tigon3 can even be told to use different interrupt mitigation
parameters when the cpu is actively servicing an interrupt for
the chip.

Didn't you say spidernet's facilities were sophisticated? :)
This Tigon3 stuff is like 5+ year old technology.
