From: Matti Aarnio <matti.aarnio@zmailer.org>
Subject: Re: Ethernet CRC questions
Date: Wed, 30 Dec 2009 08:43:24 +0200
Message-ID: <20091230064324.GJ3486@mea-ext.zmailer.org>
References: <f4f837ab0912290917h626bcfecy34fe095a878e733c@mail.gmail.com>
 <1262108376.5941.5.camel@localhost>
 <f4f837ab0912292153l7086b631o6e0012d9049eecdb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: thomas yang <lampsu@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from z2.cat.iki.fi ([212.16.98.133]:49360 "EHLO mea-ext"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751982AbZL3Gnb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 30 Dec 2009 01:43:31 -0500
Received: (mea@mea-ext) by mail.zmailer.org id S2263366AbZL3GnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Dec 2009 08:43:24 +0200
Content-Disposition: inline
In-Reply-To: <f4f837ab0912292153l7086b631o6e0012d9049eecdb@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 30, 2009 at 01:53:09PM +0800, thomas yang wrote:
> 2009/12/30 Ben Hutchings <bhutchings@solarflare.com>:
> > On Wed, 2009-12-30 at 01:17 +0800, thomas yang wrote:
> >> How does Linux =A0generate Ethernet CRC ?
> >> by the hardware (Ethernet controller) =A0or =A0use crc32_le() /
> >> crc32_be() =A0 =A0 ( lib/crc32.c ) =A0?
> >>
> >> P.S. =A0 my =A0network card is =A0rtl8139d =A0, use =A08139too dri=
ver
> >
> > The Ethernet frame CRC is normally generated and verified in hardwa=
re.
> > These library functions are needed for the few MACs that don't, or =
where
> > the same CRC function is used for some other purpose (e.g. as a has=
h
> > function for multicast filtering).
>=20
> Does the Ethernet frame CRC (generate and verify in hardware)  make
> the TX / RX  rate  a little smaller , and a longer end-to-end  delay =
?
>  Could I disable CRC appending / verifying  in the network card drive=
r
>   on all of my nodes (machines) ?

You would need to similarly disable the checking and generating at your
network switches as well.  It really is not worthwhile.

You are better to use multiple links in between the machines in paralle=
l,
and bond them together as load-sharing link.  Or go to 10G.
(We used to do that kind of things with quad fast-ethernet cards, but
with gigaethers we did not bother anymore.)

> Thanks.

Best Regards,  Matti Aarnio
