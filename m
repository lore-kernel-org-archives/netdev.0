From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] SSB: make it depend on PCI
Date: Thu, 06 Nov 2008 12:29:42 +0100
Message-ID: <1225970982.3619.211.camel@johannes.berg>
References: <1225965082-31462-1-git-send-email-vapier@gentoo.org>
	 <1225969620.3619.204.camel@johannes.berg>
	 <8bd0f97a0811060315j7d11e1a7p257a4a1bea640f7b@mail.gmail.com>
	 <1225970573.3619.208.camel@johannes.berg>
	 <8bd0f97a0811060326n5bcfc17fm5b5a65b12e71ea61@mail.gmail.com>
	 (sfid-20081106_122638_686396_E5B26AF5)
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1; protocol="application/pgp-signature"; boundary="=-sF1LaDpZdCa97DB8dVyn"
Cc: Mike Frysinger <vapier@gentoo.org>, Michael Buesch <mb@bu3sch.de>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Mike Frysinger <vapier.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:46712 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753497AbYKFL3p (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Nov 2008 06:29:45 -0500
In-Reply-To: <8bd0f97a0811060326n5bcfc17fm5b5a65b12e71ea61@mail.gmail.com> (sfid-20081106_122638_686396_E5B26AF5)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-sF1LaDpZdCa97DB8dVyn
Content-Type: text/plain
Content-Transfer-Encoding: quoted-printable

On Thu, 2008-11-06 at 06:26 -0500, Mike Frysinger wrote:
> On Thu, Nov 6, 2008 at 06:22, Johannes Berg wrote:
> > On Thu, 2008-11-06 at 06:15 -0500, Mike Frysinger wrote:
> >> while that may be the intent, it doesnt work today.
> >>
> >> drivers/ssb/main.c always includes linux/ssb/ssb.h
> >>
> >> linux/ssb/ssb.h always calls pci_dma_* functions
> >>
> >> arches that do not support PCI fail to build:
> >>   CC      drivers/ssb/main.o
> >> In file included from drivers/ssb/ssb_private.h:5,
> >>                  from drivers/ssb/main.c:12:
> >> include/linux/ssb/ssb.h: In function 'ssb_dma_mapping_error':
> >> include/linux/ssb/ssb.h:430: error: implicit declaration of function '=
pci_dma_mapping_error'
> >> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_for_cpu':
> >> include/linux/ssb/ssb.h:475: error: implicit declaration of function '=
pci_dma_sync_single_for_cpu'
> >> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_for_device':
> >> include/linux/ssb/ssb.h:493: error: implicit declaration of function '=
pci_dma_sync_single_for_device'
> >> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_range_for_cp=
u':
> >> include/linux/ssb/ssb.h:517: error: implicit declaration of function '=
dma_sync_single_range_for_cpu'
> >> include/linux/ssb/ssb.h: In function 'ssb_dma_sync_single_range_for_de=
vice':
> >> include/linux/ssb/ssb.h:538: error: implicit declaration of function '=
dma_sync_single_range_for_device'
> >> drivers/ssb/main.c: In function 'ssb_dma_set_mask':
> >> drivers/ssb/main.c:1183: error: implicit declaration of function 'dma_=
set_mask'
> >
> >
> > That seems odd, shouldn't at least the dma_sync_* functions and
> > dma_set_mask be supported?
>=20
> i'm highlighting the pci-specific functions.  the common dma functions
> missing are not a ssb problem, so ignore those ;).

Alright, but even then you'll fail build if you enable SSB ;) I guess we
need ifdefs or mandate that non-PCI architectures have dummy stubs (like
other architectures have in the !CONFIG_PCI case), but Michael's the SSB
expert.

johannes

--=-sF1LaDpZdCa97DB8dVyn
Content-Type: application/pgp-signature; name=signature.asc
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Comment: Johannes Berg (powerbook)

iQIcBAABAgAGBQJJEtUhAAoJEKVg1VMiehFYM28QAJHD+t3ptnIv7mgmQ4vtNAnl
QlKecSVKC1LJN2W06tnr8uOEei/LNgOaEPmxGXhsZ8kurBukhz33dMzynqRYw3i6
qzp7fGSZ5uwCsSR8EfIPkcXDS8FUIhEhyfRdRRS+aJkGfiReninjoZzqwghisRo9
LxznJZzdD0LTD3hs0G3TxR9i0Edt7yqpbHv5oU7wYOkUrympfIh1eCvY/DZtoGLg
Y9kBVkBWpygcoa0N9H1tL1cvcE3S/VEiSukdiysTK4qRgXusf3RMk+tzhlH4eWS7
bx3Cc+9sXSh+h0uyaX989NqiKzP+kNPD5OuLMy+8Nq0OYPfUFqdxiczmAGV7DQ7L
jWiP9OkHLfYgewfQkuB3sQ36xxt5eGGYlmKfs8mxccC0kmNYNGbxyBKpU2SuMGPr
+58wJkyt/biydLE0iekdt7yGCExfzAxli573h5BqtDk/9egWxIGfnu3AUCy+PM9Y
Kjzndo4lQpjKmy2vJz3fZbR2HemKeP4Fdbd6TMp0NrgOo6DM+34y/IsaJno8lWrd
WNZkVe7chHi2Y8QVqdwjOSG4S/GTAOrBXuO6981FQK6mgStakkyOU5MfR57n+Lm3
AzsXZJ3VJ9VM4vDCg+Ni5NA9NKq/BAOyqalKUQKT1SYXG0zXElTe3I+Z0tAACePf
6a8PkP4hBcSx09Nu0PKH
=cXqB
-----END PGP SIGNATURE-----

--=-sF1LaDpZdCa97DB8dVyn--

