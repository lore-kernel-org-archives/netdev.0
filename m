From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [pull request][for-next] Mellanox mlx5 Reorganize core driver
 directory layout
Date: Fri, 13 Jan 2017 22:29:32 +0200
Message-ID: <20170113202932.GS20392@mtr-leonro.local>
References: <1484241755-17603-1-git-send-email-saeedm@mellanox.com>
 <20170113.121407.448230751444957957.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="2qwbT0JTInWqknst"
Cc: saeedm@mellanox.com, dledford@redhat.com, netdev@vger.kernel.org,
        linux-rdma@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:50602 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751092AbdAMU3c (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Jan 2017 15:29:32 -0500
Content-Disposition: inline
In-Reply-To: <20170113.121407.448230751444957957.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--2qwbT0JTInWqknst
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, Jan 13, 2017 at 12:14:07PM -0500, David Miller wrote:
> From: Saeed Mahameed <saeedm@mellanox.com>
> Date: Thu, 12 Jan 2017 19:22:34 +0200
>
> > This pull request includes one patch from Leon, this patch as described
> > below will change the driver directory structure and layout for better,
> > logical and modular driver files separation.
> >
> > This change is important to both rdma and net maintainers in order to
> > have smoother management of driver patches for different mlx5 sub modules
> > and smoother rdma-next vs. net-next features submissions.
> >
> > Please find more info below -in the tag commit message-,
> > review and let us know if there's any problem.
> >
> > This change doesn't introduce any conflicts with the current mlx5
> > fixes and cleanups posted on 2017-01-10 to net branch, and merge tests
> > worked flawlessly with no issues.
> >
> > This is the last pull request meant for both rdma-next and net-next.
> > Once pulled, this will be the base shared code for both trees.
>
> This is pretty crazy, it will make all bug fix backporting to -stable
> a complete nightmare for myself, Doug, various distribution maintainers
> and many other people who quietly have to maintain their own trees and
> do backporting.

Hi Dave,

I understand your worries, but our case is similar to various other
drivers, for example hfi1 which was in staging for years while
supported in RedHat and moved from there to IB. The Chelsio drivers did
similar reorg in 2016 (drivers/net/ethernet/chelsio/libcxgb) while their
drivers were in the tree for long time before.

Additionally, Doug doesn't need to maintain -stable queue and it is done
by relevant submaintainers who are adding stable tags by themselves. In
the IB case, the burden will continue to be on me and not on Doug.

>
> I really don't think you can justify this rearrangement based upon the
> consequences and how much activity happens in this driver.
>
> You should have thought long and hard about the layout a long time ago
> rather than after the driver has been in the tree for many years.
>
> Sorry.

--2qwbT0JTInWqknst
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh5OKwACgkQ5GN7iDZy
WKdJlQ/9FOlyZDsLDasa7G6hqceuIImeEREBPu19Lc1ncPrNyGwnGwBI5cVBeeBt
OrEUEF57gS0XgXxm66S2kRyMrs1b+NaZRwonXVSlVWqpGVO7YrbEMRNNaHE00IZg
PiZi2xJs6qnbtTqKzvcSG2/7d3Uy+rnEVh9KgzwHzaTP66MNMDjKsK2O3LbWmlLJ
aLqRE+rdquvlA0uJiq25FYF0JBakuR3TyzELWfOJEVqAs2oJDl95hVNebohvBiAb
etXYW3q9KE+6QnE7/ePS7nJBjjoUrmSXyR6OSBryiQTLRs7DTwj2GuanRQ9Sp8HZ
dWNFphhL2/055Et3t363nGGR8qwrES20gAduMgZ78pY+Z2iBtd6TOTzT/qHomZwK
V0/dCrtQdCJ4cxvAJSPEGBHFLi9LukTvIKyCEl6/o5NIASWntlDmK16d706ujxk3
6p1rb/tp4UlaWJ/zZQCAlwT+mbLx1V6QyO7YyzIgdjxdLkwgNuyBwuG/D3sywwJB
g6HvsLDztUVhwv/4PGpc0EG0Jhq4DZ2Txw+PyWMbhJvQrJtO45NBh0E87dnixBpP
wT/zfs/53acyvLUrGcasYwniwJ/wg1U8c3nP8l46wZDFqS5RtZEZUFSkfUDbttK2
X0e1KlMZE1EzOppcObE3glXIYdFI92ufL8GXJ8bg/7h6Fr3S1KM=
=0eYg
-----END PGP SIGNATURE-----

--2qwbT0JTInWqknst--
