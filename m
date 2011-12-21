From: Ben Hutchings <ben-/+tVBieCtBitmTQ+vhA3Yw@public.gmane.org>
Subject: [PATCH 0/8] Fix virtual and physical address types
Date: Wed, 21 Dec 2011 01:29:00 +0000
Message-ID: <1324430940.2844.144.camel@deadeye>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-auuee/X1upD+bQMYrTHk"
Cc: Steve Wise <swise-ut6Up61K2wZBDgjK7y7TUQ@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Kevin Curtis <kevin.curtis-AP8L3A0T/wQqdlJmJB21zg@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, David Airlie <airlied-cv59FeDIM0c@public.gmane.org>,
	dri-devel-PD4FTy7X32lNgt0PjOBp9y5qC8QIuHrW@public.gmane.org,
	"James E.J. Bottomley" <JBottomley-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	linux-scsi <linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Hans J. Koch" <hjk-vqZO0P4V72/QD6PfKP4TzA@public.gmane.org>,
	Greg Kroah-Hartman <gregkh-l3A5Bk7waGM@public.gmane.org>,
	Venkat Venkatsubra <venkat.x.venkatsubra-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	rds-devel-N0ozoZBvEnrZJqsBc5GL+g@public.gmane.org,
	Anil Ravindranath <anil_ravindranath-4W7cOCfLBmzY0TyS/+Ba5Q@public.gmane.org>
To: LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--=-auuee/X1upD+bQMYrTHk
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

This series fixes compiler warnings on some architectures about implicit
conversions and narrowing conversions between pointer and integer types.

Please apply these to the appropriate trees.

Ben.

Ben Hutchings (8):
  IB/cxgb4: Fix formatting of physical address
  farsync: Fix confusion about DMA address and buffer offset types
  drm: Do not include page offset in argument to virt_to_page()
  drm: Pass pointers to virt_to_page()
  [SCSI] tgt: Pass pointers to virt_to_page(), not integers
  uio: Pass pointers to virt_to_page(), not integers
  rds: Pass pointers to virt_to_page(), not integers
  pmcraid: Pass pointers to access_ok(), not integers

 drivers/gpu/drm/drm_pci.c            |    4 ++--
 drivers/gpu/drm/drm_vm.c             |    2 +-
 drivers/infiniband/hw/cxgb4/device.c |    4 ++--
 drivers/net/wan/farsync.c            |   19 +++++++------------
 drivers/scsi/pmcraid.c               |    3 ++-
 drivers/scsi/scsi_tgt_if.c           |    2 +-
 drivers/uio/uio.c                    |    6 ++++--
 net/rds/message.c                    |    2 +-
 8 files changed, 20 insertions(+), 22 deletions(-)

--=20
1.7.7.3



--=-auuee/X1upD+bQMYrTHk
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.11 (GNU/Linux)

iQIVAwUATvE2XOe/yOyVhhEJAQpCPBAAzxsxERWWaiZhuyPldAGrhVCYw5gYv014
kiOOfmLRnZXeRxRVFi7ZJlV603NvxDWL3/FGtjFvwDI5CTxb6wqWjjzvp+fCcaET
O6pv6ehpvSISQM0mmkpv2shy8+f7+IZtVB9xRpPmWnQ4lE2Nbc5JhjqQcmBb4bPx
QYymccb4Xivg1a4i9R0zMeKsQ9oNS+SqZy3zJmGNhUFVVc7f/OChbXfGueFHtJ0u
NOZz7bA9wD+tbm6PkGjjHpZ7vWPIDcJQ/n5CRo9LSgSY7BwwTLHd8Cwgz7tzrfTt
emvQHA8kqN9tob486h02GAj3ny9GwfQZb6wDRsrmbhw4ahbeULlzfOxjLW76f0kf
OmyE4xqFx7PqCJD8bT3Sw/JDCtF08CguJabEXpqzAPkgc+rmGdYr9pTxlJ1WeHCZ
Q+Sv/pD88Jmn2USwg5fTNZcrTny39e4wMmLY1qKU5md5Z01RfQhEpzXWczrjIWeH
hBR3GJr29lS4uodvex9hoMIK+N+KxIeWQe6o4lTcKuCQ6RjanB+z9CKTe7yejQri
rvoHHmdkFFa/6nKDYNkp9UmODE4Aja3f1BRn/9VLEtztT4GRL2C+DY+bSI2ZpZXn
wb/MG88Q00OZi5qQaHR2V2/fT+0V93xCgx+YLqHEei22Y75tQxgbujzXnzlOYjrn
jju3au81Fks=
=gkq1
-----END PGP SIGNATURE-----

--=-auuee/X1upD+bQMYrTHk--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
