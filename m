From: Laurent Pinchart <laurentp@cse-semaphore.com>
Subject: Re: dm9000: Remove the 2 resources probe scheme.
Date: Mon, 16 Jun 2008 10:46:48 +0200
Message-ID: <200806161046.50534.laurentp@cse-semaphore.com>
References: <200806131458.58410.laurentp@cse-semaphore.com> <386072610806130729k77d1801lb615ffafb3d0117f@mail.gmail.com> <20080615214904.GR31817@trinity.fluff.org>
Mime-Version: 1.0
Content-Type: multipart/signed;
  boundary="nextPart6495100.5XgpxFqLQj";
  protocol="application/pgp-signature";
  micalg=pgp-sha1
Content-Transfer-Encoding: 7bit
Cc: Bryan Wu <cooloney@kernel.org>, netdev@vger.kernel.org
To: Ben Dooks <ben-linux@fluff.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay005.isp.belgacom.be ([195.238.6.171]:30669 "EHLO
	mailrelay005.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754415AbYFPIqx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Jun 2008 04:46:53 -0400
In-Reply-To: <20080615214904.GR31817@trinity.fluff.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--nextPart6495100.5XgpxFqLQj
Content-Type: text/plain;
  charset="ansi_x3.4-1968"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Sunday 15 June 2008 23:49, Ben Dooks wrote:
> On Fri, Jun 13, 2008 at 10:29:45PM +0800, Bryan Wu wrote:
> > On Fri, Jun 13, 2008 at 8:58 PM, Laurent Pinchart
> > <laurentp@cse-semaphore.com> wrote:
> > > The dm9000 driver accepts either 2 or 3 resources to describe the
> > > platform devices. The 2 resources case abuses the ioresource mechanism
> > > by passing ioremap()ed memory through the platform device resources.
> > > This patch removes that case and converts boards that were using it to
> > > the 3 resources scheme.=20
> > >
> > > Signed-off-by: Laurent Pinchart <laurentp@cse-semaphore.com>
> > > ---
> > >  arch/blackfin/mach-bf527/boards/ezkit.c         |    7 ++-
> > >  arch/blackfin/mach-bf533/boards/H8606.c         |    7 ++-
> > >  arch/blackfin/mach-bf537/boards/generic_board.c |    7 ++-
> > >  arch/blackfin/mach-bf537/boards/stamp.c         |    7 ++-
> >=20
> > IMO, this patch can be split into two parts, one for Blackfin and the
> > other for dm9000 driver.
>=20
> I think I agree with that, although I would also like to make sure the
> blackfin part of this is tested. I am also trying to get rid of the
> defines for blackfin specific compile, as they shouldn't be in the
> driver!
>=20
> I've queued the dm9000 specific bits into my own little dm9000 tree
> for the next kernel release.

Thanks. Should I resubmit a blackfin-specific patch (I obviously won't be a=
ble=20
to test it, as I have no blackfin hardware) or will you take care of it ?

=2D-=20
Laurent Pinchart
CSE Semaphore Belgium

Chaussee de Bruxelles, 732A
B-1410 Waterloo
Belgium

T +32 (2) 387 42 59
=46 +32 (2) 387 42 75

--nextPart6495100.5XgpxFqLQj
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)

iD8DBQBIVih68y9gWxC9vpcRArdhAKDTrEycm48/2KNwSWS/EykIYW7eTgCgivck
1eR/VmZMYvsFTWohAGHUxxw=
=pgA1
-----END PGP SIGNATURE-----

--nextPart6495100.5XgpxFqLQj--
