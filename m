From: Wolfgang Walter <linux@stwm.de>
Subject: Re: linux 3.13: problems with isatap tunnel device and UFO
Date: Fri, 07 Feb 2014 19:17:40 +0100
Message-ID: <1720760.5dnaEcLin5@h2o.as.studentenwerk.mhn.de>
References: <1682505.dP4nT04FC9@h2o.as.studentenwerk.mhn.de> <20140207175641.GB16198@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailin.studentenwerk.mhn.de ([141.84.225.229]:38951 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751875AbaBGSRm convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Feb 2014 13:17:42 -0500
In-Reply-To: <20140207175641.GB16198@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Freitag, 7. Februar 2014, 18:56:41 schrieb Hannes Frederic Sowa:
> Hi!
>=20
> On Fri, Feb 07, 2014 at 06:47:07PM +0100, Wolfgang Walter wrote:
> > with kernel 3.13 I have a problem with isatap tunnels receiving fra=
gmented
> > ipv6 udp packets.
>=20
> Which was the last known version that did work?

I think 3.12 had no problems, but I'm not sure. I test this tonight.

> Also dropwatch and nstat
> could give a first hint.
>=20
> > If I switch of ufo for the tunnel device the problem disappears:
> > 	ethtool -K is0 ufo off
> >=20
> > When UFO is on tcpdump shows the packets on the physical device but=
 not on
> > the tunnel device. The packets seem to be discarded.
> >=20
> > With UFO off I can see them on is0 (and the packet is delivered to =
the
> > socket).
>=20
> Thanks for the report, I'll look at it.
>=20
> Greetings,
>=20
>   Hannes
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
