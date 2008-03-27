From: David Miller <davem@davemloft.net>
Subject: Re: tx-checksumming for an Intel Corporation 82540EP Gigabit
 Ethernet Controller (Mobile)
Date: Thu, 27 Mar 2008 04:01:39 -0700 (PDT)
Message-ID: <20080327.040139.233337573.davem@davemloft.net>
References: <200803271144.52812.toralf.foerster@gmx.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: toralf.foerster@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57779
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754534AbYC0LBj convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Mar 2008 07:01:39 -0400
In-Reply-To: <200803271144.52812.toralf.foerster@gmx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Toralf F=F6rster <toralf.foerster@gmx.de>
Date: Thu, 27 Mar 2008 11:44:52 +0100

> I'm wondering why I have to add this line in my startup scripts :=20
>=20
> $> /usr/sbin/ethtool -K eth0 tx off
> to avoid that all outgoing packets have bad check sums (seen with wir=
eshark).
>=20
> Wouldn't it makes sense to make this behaviour as default ?

The checksums are computed by the card, so the packets seen by
wireshark simply haven't been checksummed by the card yet.
