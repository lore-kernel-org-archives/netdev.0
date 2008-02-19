From: "Reither Robert" <Robert.Reither@av-digital.at>
Subject: AW: AW: AW: Problem receiving multicast with kernel.2.6.24, REAL solution
Date: Tue, 19 Feb 2008 15:47:20 +0100
Message-ID: <BA41E8A07B73A041948C2E3A4EF6239D062F1B@av-digital-exch.avdigital.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>
To: "Patrick McHardy" <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.av-digital.at ([88.116.237.238]:27980 "EHLO
	av-digital-exch.avdigital.at" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1757965AbYBSOrW convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 19 Feb 2008 09:47:22 -0500
Content-Class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Visit AVD on prolight+sound in Frankfurt from 12.-15. March 2008 - Hall=
 8.0, Stand G16
_______________________________________________________________________=
_



Hurray, your patch does the trick for me !!!

Now join/leave und receiving of multicasts work like it should !!

May i kiss you Patrick, this saves my week ;-)

Hope we see a minor kernel release with this patch very soon ...

Greetings
Robert

-----Urspr=FCngliche Nachricht-----
Von: Patrick McHardy [mailto:kaber@trash.net]
Gesendet: Dienstag, 19. Februar 2008 15:03
An: Reither Robert
Cc: David Stevens; netdev@vger.kernel.org
Betreff: Re: AW: AW: Problem receiving multicast with kernel.2.6.24 #3

>=20
> OK, found one solution (but i think, this should not the normal way)
>=20
> MC joining first the VLAN device (eth0.3) and than the physical (eth0=
) does the trick, 100% success ...
>=20
> Doing it the opposite way, gives the same problem as before ...
>=20
> So somehow joining the VLAN interface disrupts the join to the physic=
al one ...
>=20
> Ideas ?

Does this patch help?
