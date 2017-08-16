From: Leon Romanovsky <leonro@mellanox.com>
Subject: Re: [PATCH v4 iproute2 1/7] rdma: Add basic infrastructure for RDMA
 tool
Date: Wed, 16 Aug 2017 08:32:49 +0300
Message-ID: <20170816053249.GC24282@mtr-leonro.local>
References: <20170815130020.29509-1-leonro@mellanox.com>
 <20170815130020.29509-2-leonro@mellanox.com>
 <20170815165416.24e9838a@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="RvYRPxT9kmUw5evD"
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-eopbgr10073.outbound.protection.outlook.com ([40.107.1.73]:8706
        "EHLO EUR02-HE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751577AbdHPFc6 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 16 Aug 2017 01:32:58 -0400
Content-Disposition: inline
In-Reply-To: <20170815165416.24e9838a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--RvYRPxT9kmUw5evD
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Aug 15, 2017 at 04:54:16PM -0700, Stephen Hemminger wrote:
> On Tue, 15 Aug 2017 16:00:14 +0300
> Leon Romanovsky <leonro@mellanox.com> wrote:
>
> > RDMA devices are cross-functional devices from one side,
> > but very tailored for the specific markets from another.
> >
> > Such diversity caused to spread of RDMA related configuration
> > across various tools, e.g. devlink, ip, ethtool, ib specific and
> > vendor specific solutions.
> >
> > This patch adds ability to fill device and port information
> > by reading RDMA netlink.
> >
> > Signed-off-by: Leon Romanovsky <leonro@mellanox.com>
>
> Won't build for me.
>
> $ make distclean
>
> $ make
>
> In file included from rdma.c:12:0:
> rdma.h:23:23: fatal error: rdma/rdma.h: No such file or directory
>  #include <rdma/rdma.h>
>                        ^
>
> I think your Makefile expects something different.
> Or more Config fallout

Your kernel tree should have this [1] pull request to be merged, because
I'm adding new header file to UAPI [2].

 create mode 100644 include/uapi/rdma/rdma.h

[1] http://marc.info/?l=linux-rdma&m=150278847820844&w=2
[2] http://marc.info/?l=linux-rdma&m=150278850520856&w=2

> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--RvYRPxT9kmUw5evD
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlmT2QEACgkQ5GN7iDZy
WKfoNQ//XmgEqnpuK04QYk76O2nlkL8EjlT5awo6vWb6XC9aj4ysjXwxxguQVB1G
gXrOS6dmpDP7zggKDlPg5aMce6pje1J01T/suuDfqq+6R3wmF7dJOFhyeA6LPT2r
IIKiRIvPbJFf7GUZrkbNHK8D96I4kWC9qh0UhCmfmcJdShuZiBVMm5QyxqNkpOdw
NV8O6Nik5AWBL7+NANA7Q0Ik8LAmACH+p89/yM9GnzrUeymxrmX75Edr88xdUeGS
+9hOUluWsNJnUabXqe3B/8QAo7ch/HgwOGSCpdXZhFTyrfiOgLsmqikqy7KLEtje
qEalHElvBy/cD6sD6U9xOaGiQpB0Rp+jSlBVwT0JPFfmtWUF7wlv04SqlYdaRTw4
nxJn9uR+LRoy75NpOxQa9JC++PZEGh+OXLCgqo/PoA9qCf868L5Db8HbxtNSxWEt
0aTqFz83M07kTx+1SS1vj40ZW9bpHdfdzkO1M4urCTVlrXjV8oC929lVOtibrD8H
sZYzGCBYzT1ACtmkG/nSdtEsUfl0l4K5RX4NWw7gLXunU+SYMICqHeMXAcP07zDz
iFPS1YPPtwb0GOdseAdxtYnH+6ZeSxZJYgFz6bIpgjDvO1NR38tc8QNfVBsb9Qfq
PNSik9+c2ToqXDTVLb4kXP3tnuXSgA+7sWFC14fJezW2kd4wzng=
=6x5H
-----END PGP SIGNATURE-----

--RvYRPxT9kmUw5evD--
