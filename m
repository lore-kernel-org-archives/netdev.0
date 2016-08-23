From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [for-next V3 00/15][PULL request] Mellanox mlx5 core driver
 updates 2016-08-20
Date: Tue, 23 Aug 2016 21:39:26 +0300
Message-ID: <20160823183926.GL15065@leon.nu>
References: <1471942157-9131-1-git-send-email-saeedm@mellanox.com>
 <1a97f16d-5a0a-cb06-6e5c-1b6f9fa7c609@redhat.com>
 <CALzJLG8=+D2a-dtaTMJWu_95Mdroh51Ph3dGths1eO3spzp58g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="w2xx78T4DcG3O+DJ"
Cc: Doug Ledford <dledford@redhat.com>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>,
        linux-rdma@vger.kernel.org, Tal Alon <talal@mellanox.com>,
        Matan Barak <matanb@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f175.google.com ([209.85.216.175]:36112 "EHLO
        mail-qt0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753660AbcHWSj3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 14:39:29 -0400
Received: by mail-qt0-f175.google.com with SMTP id 52so45457722qtq.3
        for <netdev@vger.kernel.org>; Tue, 23 Aug 2016 11:39:28 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <CALzJLG8=+D2a-dtaTMJWu_95Mdroh51Ph3dGths1eO3spzp58g@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--w2xx78T4DcG3O+DJ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, Aug 23, 2016 at 07:10:53PM +0300, Saeed Mahameed wrote:
> On Tue, Aug 23, 2016 at 6:57 PM, Doug Ledford <dledford@redhat.com> wrote:
> > On 8/23/2016 4:49 AM, Saeed Mahameed wrote:
> >> Hi Dave and Doug,
> >>
> >> This series contains several low level and API updates for mlx5 core
> >> commands interface and mlx5_ifc.h to be shared as base code for net-ne=
xt and
> >> rdma mlx5 4.9 submissions.
> >>
> >> From Saeed, ten patches that refactors old layouts of firmware command=
s which
> >> were manually generated before we introduced the mlx5_ifc, now all of =
the firmware
> >> commands inbox/outbox layouts moved to use mlx5_ifc and we remove the =
old
> >> manually generated structures.
> >
> > These all looked fine to me.
> >
> >> Plus to those ten patches, we add two patches
> >> that unifies mlx5 commands execution interface and improve the driver =
log messages
> >> in that area.
> >
> > These are the patches that made my eyes want to bleed.  But, since it's
> > all changes to the mailbox commands being sent to your device, they are
> > easy to verify operationally, so I only gave these a cursory review and
> > expect if any of your commands broke because of this you'll be
> > submitting fixes ASAP.
> >
>=20
> Thanks Doug for your review those patches already passed all kinds of
> our internal regression testings.
> What is nice about those patches is that they remove  ~1K  LOC from
> driver and unify the command interface.

Thanks for taking them.
One of the reasons for such a long delay of shared code submission was our
desire to take extra care and test these patches again and again.

>=20
> >
> >> From Hadar and Ilya, added the needed hardware bits and infrastructure=
 for
> >> minimum inline headers setting and encap/decap commands and capabiliti=
es,
> >> needed for E-Switch offloads.
> >
> > These looked fine to me, but aren't really in the RDMA area anyway.

Our internal goal is to have 0-merge conflicts between RDMA and net
trees.

--w2xx78T4DcG3O+DJ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJXvJhdAAoJEORje4g2clinjnkQAMPU5iBtkEw4MnVtPxgmPWwB
9Lz0gKgV1BVAFtzMu7l2MDinur8klKLDCykrBeMfx8FaLPbaHNE5NgE52PwgC7xt
BwSV6KxX/TzMITO35Z6W8vSIGbRqMmdSV2wClpzBZUHZTEI1q6kr+H18DvVM1VeA
UduXv2ElKsyO2Mym6xNfkrTVVMuj89HOx2n465NSWhcT1DBNF9aXoRbgDEPHt47i
jUtgO2u63oAfkFV5puOmcH/tFJhBFSbBBQJmL20K5EkC/lplxnyRPcUApbt8R6U6
vqwzKsxJXSZIgtt3bGCO8olDtOWhGnnww+dOb1FjbwsRjXU/+SH2pfLTCCuj+dZF
cUEvJgVO/7qgDcZSTJ0Q5jNyFmK35pnmUjh4VUcWWJG3siJnuCm4IMLBOqVWLkZL
2aNUQNwwH2+5LIzCS4+8fzshR9N4vqhV5aH8jyfL+ZW8kq63yOj8XIXb8kdfCUsq
or4jeFzKFqpifycCm+DOBcu4HN13uCSrZEvnQHntp5J+MJq4QEajz8WtpeSjbAWJ
TqOTTEkpAqZLyj7f67E4yCq8tO6XRRpFG/y/v50cpTrOkJOUsj4/5pfiwsx3NvLL
yVcSmu/zjNyo7In2c60106/S/ETzKH6ZxS7TMqGH7jSlWH20uCUGtF2qRTk8jZ3G
tQ/Jbs/nqDymE4p3yyBj
=Ho/F
-----END PGP SIGNATURE-----

--w2xx78T4DcG3O+DJ--
