From: Arvid Brodin <arvid.brodin@xdin.com>
Subject: Re: [PATCH v6] net/hsr: Add support for the High-availability Seamless
 Redundancy protocol (HSRv0)
Date: Mon, 4 Nov 2013 20:34:46 +0100
Message-ID: <5277F6D6.9040807@xdin.com>
References: <527167C7.4030305@xdin.com> <1383164122.9435.41.camel@joe-AO722>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Javier Boticario <jboticario@gmail.com>,
	"balferreira@googlemail.com" <balferreira@googlemail.com>,
	=?ISO-8859-1?Q?El=EDas_Molina_Mu=F1oz?= <elias.molina@ehu.es>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spam1.webland.se ([91.207.112.90]:56789 "EHLO spam1.webland.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750791Ab3KDTet (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Nov 2013 14:34:49 -0500
In-Reply-To: <1383164122.9435.41.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-10-30 21:15, Joe Perches wrote:
> On Wed, 2013-10-30 at 21:10 +0100, Arvid Brodin wrote:
>> High-availability Seamless Redundancy ("HSR") provides instant failo=
ver
>> redundancy for Ethernet networks. It requires a special network topo=
logy where
>> all nodes are connected in a ring (each node having two physical net=
work
>> interfaces). It is suited for applications that demand high availabi=
lity and
>> very short reaction time.
>=20
> Thanks Arvid.  Maybe add a MAINTAINERS entry too?

Something like this?

 S:     Maintained
 F:     drivers/net/usb/hso.c
=20
+HSR NETWORK PROTOCOL
+M:     Arvid Brodin <arvid.brodin@xdin.com>
+L:     netdev@vger.kernel.org
+S:     Maintained
+F:     net/hsr/*
+
 HTCPEN TOUCHSCREEN DRIVER
 M:     Pau Oliva Fora <pof@eslack.org>
 L:     linux-input@vger.kernel.org

This would indicate that people should CC me when they send patches or =
find bugs,=20
and that I should review the patch within a couple of weeks and get bac=
k to the
sender and the list with my comments, right? Just making sure I underst=
and what=20
would be expected of me.

And where should the MAINTAINERS patch go - to netdev or to lkml?


--=20
Arvid Brodin | Consultant (Linux)
XDIN AB | Knarrarn=E4sgatan 7 | SE-164 40 Kista | Sweden | xdin.com
