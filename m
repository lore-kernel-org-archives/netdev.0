From: Shawn Lu <shawn.lu@ericsson.com>
Subject: RE: [PATCH v3 1/2] Implement IP_UNICAST_IF socket option.
Date: Mon, 6 Feb 2012 14:40:22 -0500
Message-ID: <62162DF05402B341B3DB59932A1FA992B5B5CA01B7@EUSAACMS0702.eamcs.ericsson.se>
References: <62162DF05402B341B3DB59932A1FA992B5B5CA0154@EUSAACMS0702.eamcs.ericsson.se>
 <CAEU2+vrvKS8e0hjkZG0j_Ukm_Fq3KJ9NnSz+Yb1R3vQnn7-vcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Netdev <netdev@vger.kernel.org>
To: "Erich E. Hoover" <ehoover@mines.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imr4.ericy.com ([198.24.6.9]:55574 "EHLO imr4.ericy.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753145Ab2BFTkh convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 14:40:37 -0500
In-Reply-To: <CAEU2+vrvKS8e0hjkZG0j_Ukm_Fq3KJ9NnSz+Yb1R3vQnn7-vcQ@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=20

> -----Original Message-----
> From: Erich E. Hoover [mailto:ehoover@mines.edu]=20
> Sent: Monday, February 06, 2012 11:35 AM
> To: Shawn Lu
> Cc: Linux Netdev
> Subject: Re: [PATCH v3 1/2] Implement IP_UNICAST_IF socket option.
>=20
> On Mon, Feb 6, 2012 at 12:00 PM, Shawn Lu=20
> <shawn.lu@ericsson.com> wrote:
> >On 2/6/12, Erich E. Hoover <ehoover@mines.edu> wrote:
> >> ...
> >> +             if (sk->sk_bound_dev_if && ifindex !=3D=20
> >> + sk->sk_bound_dev_if)
> > If I understand right,=A0 when sk->sk_bound_dev_if !=3D0 ,=A0=20
> > sk->sk_bound_dev_if will be used instead. Then why bother=20
> to set outif_index.
> > Here.
>=20
> It seems to me that if the socket is already bound to an=20
> interface (other than intended interface) then it makes sense=20
> to fail to set the option, since it will clearly not work=20
> under this circumstance.  I may be misunderstanding you though.
What I mean is replace=20
  if (sk->sk_bound_dev_if && ifindex !=3D sk->sk_bound_dev_if)
With=20
  if (sk->sk_bound_dev_if)
>=20
> Erich Hoover
> ehoover@mines.edu
> 