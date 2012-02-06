From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH v3 1/2] Implement IP_UNICAST_IF socket option.
Date: Mon, 6 Feb 2012 15:30:10 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5CA0245@EUSAACMS0702.eamcs.ericsson.se>
References: <62162DF05402B341B3DB59932A1FA992B5B5CA0154@EUSAACMS0702.eamcs.ericsson.se>
	<CAEU2+vrvKS8e0hjkZG0j_Ukm_Fq3KJ9NnSz+Yb1R3vQnn7-vcQ@mail.gmail.com>
	<62162DF05402B341B3DB59932A1FA992B5B5CA01B7@EUSAACMS0702.eamcs.ericsson.se>
 <CAEU2+vrS_HmpUmcSkrsGq0RYZxynYmXrY_Pm9ESa=280kEqSgg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:34735 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755401Ab2BFUaU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 15:30:20 -0500
In-Reply-To: <CAEU2+vrS_HmpUmcSkrsGq0RYZxynYmXrY_Pm9ESa=280kEqSgg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=20

> -----Original Message-----
> From: Erich E. Hoover [mailto:ehoover@mines.edu]=20
> Sent: Monday, February 06, 2012 11:51 AM
> To: Shawn Lu
> Cc: Linux Netdev
> Subject: Re: [PATCH v3 1/2] Implement IP_UNICAST_IF socket option.
>=20
> On Mon, Feb 6, 2012 at 12:40 PM, Shawn Lu=20
> <shawn.lu@ericsson.com> wrote:
> >...
> > What I mean is replace
> > =A0if (sk->sk_bound_dev_if && ifindex !=3D sk->sk_bound_dev_if)  Wi=
th
> > =A0if (sk->sk_bound_dev_if)
>=20
> Are you sure that that's appropriate?  I choose to do it this=20
> way since IP_MULTICAST_IF does the exact same check.
If sk->sk_bound_dev_if has a value,  we are not going to use
outif_index anywhere. Seting outif_index is confusing in this case,

In addition,  when socket has bond to specific device, this
Option should return fail to indicate it is wrong to use  IP_UNICAST_IF
Here.
>=20
> Erich Hoover
> ehoover@mines.edu
> 