From: Michael =?UTF-8?B?QsO8c2No?= <m@bues.ch>
Subject: Re: [PATCH] ssb: Fix Sparse error in main
Date: Wed, 1 Oct 2014 15:27:05 +0200
Message-ID: <20141001152705.02f4f34e@wiggum>
References: <1412147196-7466-1-git-send-email-pramod.gurav@smartplayin.com>
 <1412148544.21730.36.camel@x220>
 <542BAFB3.6030207@smartplayin.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
 boundary="Sig_/WkksWX0=7dNSbjP8muOd0He"; protocol="application/pgp-signature"
Cc: Paul Bolle <pebolle@tiscali.nl>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Pramod Gurav <pramod.gurav@smartplayin.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <542BAFB3.6030207@smartplayin.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Sig_/WkksWX0=7dNSbjP8muOd0He
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable

On Wed, 01 Oct 2014 13:09:31 +0530
Pramod Gurav <pramod.gurav@smartplayin.com> wrote:

> On Wednesday 01 October 2014 12:59 PM, Paul Bolle wrote:
> > On Wed, 2014-10-01 at 12:36 +0530, Pramod Gurav wrote:
> >> This change fixes below sparse error:
> >>
> >> drivers/ssb/main.c:94:16: warning: symbol 'ssb_sdio_func_to_bus'
> >> was not declared. Should it be static?
> >>
> >> Cc: Michael Buesch <m@bues.ch>
> >> Cc: netdev@vger.kernel.org
> >> Signed-off-by: Pramod Gurav <pramod.gurav@smartplayin.com>
> >> ---
> >>  drivers/ssb/ssb_private.h |    1 +
> >>  1 file changed, 1 insertion(+)
> >>
> >> diff --git a/drivers/ssb/ssb_private.h b/drivers/ssb/ssb_private.h
> >> index eb507a5..86bbbe3 100644
> >> --- a/drivers/ssb/ssb_private.h
> >> +++ b/drivers/ssb/ssb_private.h
> >> @@ -193,6 +193,7 @@ extern struct ssb_bus *ssb_pci_dev_to_bus(struct p=
ci_dev *pdev);
> >>  int ssb_for_each_bus_call(unsigned long data,
> >>  			  int (*func)(struct ssb_bus *bus, unsigned long data));
> >>  extern struct ssb_bus *ssb_pcmcia_dev_to_bus(struct pcmcia_device *pd=
ev);
> >> +struct ssb_bus *ssb_sdio_func_to_bus(struct sdio_func *func);
> >> =20
> >>  struct ssb_freeze_context {
> >>  	/* Pointer to the bus */
> >=20
> > To me this looked like an odd way to silence that warning. So I dug a
> > bit further.
> >=20
> > ssb_sdio_func_to_bus() was added in commit 24ea602e183c ("ssb: Implement
> > SDIO host bus support"). So it was added in release v2.6.32. I found no
> > evidence this function was ever used. Can't it be removed?
> >=20
> Thanks Paul for review. Initially I too had greped for this function in
> kernel and found noone using it. But I thought this function might be
> useful in future. About removing it, may be original author can tell.


If it's unused, please remove it.



--=20
Michael

--Sig_/WkksWX0=7dNSbjP8muOd0He
Content-Type: application/pgp-signature; name=signature.asc
Content-Disposition: attachment; filename=signature.asc

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAEBAgAGBQJULAEpAAoJEPUyvh2QjYsOTycP/1fm+VZJ/UPvhUgso6QEDawL
IegdwpmygYLVHok8wIFTLPLXGCbdno3MDcwwnjt/UhZOxbFWTIlu5uubhMWPAVkA
o2Ih83ake89yV/uhRZjW7Gsr0vYH79+46gDSpCGHuQ4GsliJoJ2FWNcN0rk9LIbe
bZEJYMxwhsep2sExYueJ8wnBVS1Pf1IxLLTSCVdBsf2HxQV6kYl/K5fw5j2o+9ja
HIYsKHhe41Ij3Vo1RU1MhuOu2TAWhCL19E3szz4AQGBN3j+cycOVOGz2rSPEDDuY
9KON6eYnXHW4cgw79Rljfx+odVHq72DyYSKO8gqauD7BSvkW36yDWVbEL6b4IaaM
9L2YKssaRR3Iyjbytzpsl0wg9h5mK+k2a1Yd4OQfFBWITSTvZ8iKWB2lgb2VwmVc
w3rVPUE62JmVeLZSt5igPp/7ygqaiMWbFOn9I5G8Nl0YDgo8J8uEFNgbUobNcy/l
8C13VTHp1DIi0GcEaKLBd40tywj49BtpsSwP7PI3kU+1enizPu1KLKZZhtXHSfu9
imxUu+WktNgZUzhbhnhyFdNK94xIwlp/0gQfA09hFwWquc5snF7rZFI+ZqzO2FQq
Fm5sHfnR4DJge4hrKyX+hB3nlqpa4NMXMJa0ZzYu8IA4PPNUbl/9IO+sOSh1GNxa
umkJi4xGfu2SzEjFG5Ny
=v7Zp
-----END PGP SIGNATURE-----

--Sig_/WkksWX0=7dNSbjP8muOd0He--
