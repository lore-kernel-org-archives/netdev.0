From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH v6 1/2] Implement IP_UNICAST_IF socket option.
Date: Wed, 8 Feb 2012 01:25:54 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5D1FD22@EUSAACMS0702.eamcs.ericsson.se>
References: <62162DF05402B341B3DB59932A1FA992B5B5D1FC8A@EUSAACMS0702.eamcs.ericsson.se>
 <CAEU2+vrfMXXr1S0BYtN07uwXfK8T8A_ob3PR3RoHOdqdFv0YEg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr3.ericy.com ([198.24.6.13]:34661 "EHLO imr3.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751270Ab2BHGZ7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2012 01:25:59 -0500
In-Reply-To: <CAEU2+vrfMXXr1S0BYtN07uwXfK8T8A_ob3PR3RoHOdqdFv0YEg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Erich E. Hoover [mailto:ehoover@mines.edu]=20
> Sent: Tuesday, February 07, 2012 5:10 PM
> To: Shawn Lu
> Cc: Linux Netdev
> Subject: Re: [PATCH v6 1/2] Implement IP_UNICAST_IF socket option.
>=20
> On Tue, Feb 7, 2012 at 5:23 PM, Shawn Lu=20
> <shawn.lu@ericsson.com> wrote:
> >> ...
> >> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 ifindex =3D (__force int)nto=
hl((__force __be32)val);
> > We always use ifindex as host byte order, why the val=A0 is=20
> passed in as=20
> > network byte order and then convert it Back to host byte order.=20
> > Anything special about it?
>=20
> Yes, the value for IP_UNICAST_IF is passed in network byte=20
> order in implementations on other operating systems.  David=20
> Miller requested that this option by passed in the same way=20
> as that of other systems.
>=20
> Erich Hoover
> ehoover@mines.edu
>=20
Ok.  V6 looks good to me.

Reviewed-by: Shawn Lu <shawn.lu@ericsson.com>