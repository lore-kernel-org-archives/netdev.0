From: Leon Romanovsky <leon@leon.nu>
Subject: Re: [PATCH for-next 2/2] net/mlx5: Update mlx5_ifc hardware features
Date: Tue, 12 Apr 2016 08:15:37 +0300
Message-ID: <20160412051537.GD25242@leon.nu>
References: <1460405422-8654-1-git-send-email-saeedm@mellanox.com>
 <1460405422-8654-3-git-send-email-saeedm@mellanox.com>
 <CAJ3xEMghu7ZB0YM8j_YJihpuNnDzOY2LU9-cTHwoWiBeYY7VPA@mail.gmail.com>
 <CALzJLG-PxUz9ov+cv4uiNSGpuxy0s9KamTvamV_g72SctqdhFA@mail.gmail.com>
 <CAJ3xEMhorMRsxtawjim9zoBn-zzoDXcMAJfHUqCZBNUbOKrMJA@mail.gmail.com>
Reply-To: leon@leon.nu
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="/3yNEOqWowh/8j+e"
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Matan Barak <matanb@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	"linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Doug Ledford <dledford@redhat.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Leon Romanovsky <leonro@mellanox.com>,
	Tal Alon <talal@mellanox.com>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:34801 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751181AbcDLFP4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2016 01:15:56 -0400
Received: by mail-wm0-f45.google.com with SMTP id l6so171922490wml.1
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2016 22:15:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CAJ3xEMhorMRsxtawjim9zoBn-zzoDXcMAJfHUqCZBNUbOKrMJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--/3yNEOqWowh/8j+e
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Apr 12, 2016 at 12:37:34AM +0300, Or Gerlitz wrote:
> On Tue, Apr 12, 2016 at 12:24 AM, Saeed Mahameed
> <saeedm@dev.mellanox.co.il> wrote:
> > On Tue, Apr 12, 2016 at 12:17 AM, Or Gerlitz <gerlitz.or@gmail.com> wro=
te:
>=20
> >> feature --> features
>=20
> > Correct, will fix.
>=20
> >>> * Add vport to steering commands for SRIOV ACL support
> >>> * Add mlcr, pcmr and mcia registers for dump module EEPROM
> >>> * Add support for FCS, baeacon led and disable_link bits to hca caps
> >>> * Add CQE period mode bit in  CQ context for CQE based CQ
> >>>   moderation support
> >>> * Add umr SQ bit for fragmented memory registration
> >>> * Add needed bits and caps for Striding RQ support
>=20
> >> AFAIK, all the above are features will go through net-next, what made
> >> you anticipate conflicts with linux-rdma?
>=20
> > FCS bit is needed also for rdma, so we took the liberty of updating
> > all the needed HW structs, bits, caps, etc ..
> > at once for all mlx5 features planned for 4.7 regardless of rdma/net co=
nflicts.
>=20
> The cover letter states that this series deals with shared code.
>=20
> I guess you might also could extend it a bit to deal also with code
> that you suspect could lead to conflicts, but I don't see why it
> evolved to that extent.

Or,
All these micro-optimizations on this shared file can potentially lead
to undesired merge conflicts. Subsystem maintainers and Linus don't need to
deal with these conflicts at all.

It won't help to anyone to split this commit to more than one patch.

--/3yNEOqWowh/8j+e
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: Digital signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXDIR5AAoJEORje4g2clinfXsQANNi8c52FZ0wJNyFg2wtamef
DDxS121NP+ML/PagK+cPOQlkM1nMOpuwfK+ejCwaoWW/IuOFI5vWnaEGGcaWkcnQ
69aj87FoKi44p8jt8DeCJXrhDILPERBUSwHkPDhaDg1KaOvzPVVC72wJ3g9znS1h
dTZjNhYDBdeyJkeunFHEIauk4aG79GQy9y79mx8vAUtElwIdGSD1HmoQzieLY18S
BmDnZ4jPUlmqtYmsDK8F+PIX2k8n6Jdd1ejugoImmO7HV5p6xAzT2ABJoXso6UMa
zvj2jtMfjb6r3vg0cdXzSxnLIYMYo+LIJMEBbDzkz89XYcFZykpRw+zYqu8of54K
xjxxHGxUuuzUuQld3J/qyKmyXYF60nYjGDmwoJZupdfCUYxa9OMuy800xtvc7BBT
JbG2/xp4ZM6BknV+QwOOeZoB7Mn8b4bpKeinW01IQlH3kg5X1VCogAb9wRuDM8GT
icL5JuMe2UJ5zzAmULZwynlTH0OlfWtDT2s5qlXOUjFQYzq4SxpNYAbAne38zY/K
N7NXvl2eNOJ9ly4mQuq8RB8xS6rOsRaBup7oxVHYz083q6zDf8kWA03NK1CuH+Gb
EfufyTiOurVmKF378xpFYUg2oPoWa6Z4XJhCiAr7NlvzBdZjbjxqwZvijaJbzRFQ
bg98d4fOMd+nbzdBH+fV
=0P19
-----END PGP SIGNATURE-----

--/3yNEOqWowh/8j+e--
