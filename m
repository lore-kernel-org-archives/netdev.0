From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V2 for-next 00/11] Code improvements & fixes for HNS RoCE
 driver
Date: Mon, 12 Dec 2016 23:34:19 -0500
Message-ID: <584499b3-5355-f8b7-1b6a-cc08c50e8c04@redhat.com>
References: <20161115181053.399568-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="R7UXdSL4eQSsawBSAX5tfaT5LFSLvLltB"
Cc: xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xushaobo2-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
        mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, lijun_nudt-9Onoh4P/yGk@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20161115181053.399568-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--R7UXdSL4eQSsawBSAX5tfaT5LFSLvLltB
Content-Type: multipart/mixed; boundary="sLfPX655iAJ7iUVGhNhG4ieWM7NOxakbf";
 protected-headers="v1"
From: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
To: Salil Mehta <salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
Cc: xavier.huwei-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, oulijun-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, xushaobo2-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
 mehta.salil.lnk-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, lijun_nudt-9Onoh4P/yGk@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
 netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linuxarm-hv44wF8Li93QT0dZR+AlfA@public.gmane.org
Message-ID: <584499b3-5355-f8b7-1b6a-cc08c50e8c04-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH V2 for-next 00/11] Code improvements & fixes for HNS RoCE
 driver
References: <20161115181053.399568-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>
In-Reply-To: <20161115181053.399568-1-salil.mehta-hv44wF8Li93QT0dZR+AlfA@public.gmane.org>

--sLfPX655iAJ7iUVGhNhG4ieWM7NOxakbf
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11/15/2016 1:10 PM, Salil Mehta wrote:
> This patchset introduces some code improvements and fixes
> for the identified problems in the HNS RoCE driver.
>=20
> Lijun Ou (4):
>   IB/hns: Add the interface for querying QP1
>   IB/hns: add self loopback for CM
>   IB/hns: Modify the condition of notifying hardware loopback
>   IB/hns: Fix the bug for qp state in hns_roce_v1_m_qp()
>=20
> Salil Mehta (1):
>   IB/hns: Fix for Checkpatch.pl comment style errors
>=20
> Shaobo Xu (1):
>   IB/hns: Implement the add_gid/del_gid and optimize the GIDs
>     management
>=20
> Wei Hu (Xavier) (5):
>   IB/hns: Add code for refreshing CQ CI using TPTR
>   IB/hns: Optimize the logic of allocating memory using APIs
>   IB/hns: Modify the macro for the timeout when cmd process
>   IB/hns: Modify query info named port_num when querying RC QP
>   IB/hns: Change qpn allocation to round-robin mode.
>=20
>  drivers/infiniband/hw/hns/hns_roce_alloc.c  |   11 +-
>  drivers/infiniband/hw/hns/hns_roce_cmd.c    |    8 +-
>  drivers/infiniband/hw/hns/hns_roce_cmd.h    |    7 +-
>  drivers/infiniband/hw/hns/hns_roce_common.h |    2 -
>  drivers/infiniband/hw/hns/hns_roce_cq.c     |   17 +-
>  drivers/infiniband/hw/hns/hns_roce_device.h |   45 ++--
>  drivers/infiniband/hw/hns/hns_roce_eq.c     |    6 +-
>  drivers/infiniband/hw/hns/hns_roce_hem.c    |    6 +-
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.c  |  267 +++++++++++++++++--=
----
>  drivers/infiniband/hw/hns/hns_roce_hw_v1.h  |   17 +-
>  drivers/infiniband/hw/hns/hns_roce_main.c   |  311 +++++++------------=
--------
>  drivers/infiniband/hw/hns/hns_roce_mr.c     |   21 +-
>  drivers/infiniband/hw/hns/hns_roce_pd.c     |    5 +-
>  drivers/infiniband/hw/hns/hns_roce_qp.c     |    2 +-
>  14 files changed, 363 insertions(+), 362 deletions(-)
>=20

Series applied, thanks.

--=20
Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
    GPG Key ID: 0E572FDD


--sLfPX655iAJ7iUVGhNhG4ieWM7NOxakbf--

--R7UXdSL4eQSsawBSAX5tfaT5LFSLvLltB
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJYT3pLAAoJELgmozMOVy/dP3oP/jdxtTnh0oU1gw6/zGMM/bFS
QpeyqJQN67qhgiCWpfFElVhk2TiIkispyJKo5Q+8Y21omft9gPIBFxEuLQRFi4q2
vD8mbeNap10F2bswbWD/ljxA3CBwSqHLZKX/qfmSet0kRi8Inup9VtwXmw6djGGk
33e7yl1q4LdrMBcpDCxhiu4Ver77kn2hXmWT46wNXfs86Ug74a3NtuNj6z2d3vOJ
0gU1YIa9xaL2KVr15f+RKLFWsOK8e1xgrq5b1tS+wFO11Zei+ebhApx9eDtQ4V7H
rX4L8a83aolMSmvaiRvFHfOf18G0XecPV9KtXNzji8hlzkvUQ8dKi6gSMgXNvOPx
az5EeKEvxhHWAKpxZJPB+CA85hn70zSnUlROXtmPZKHfyl+MFNYKw9gChxdaDxQ8
BIXwZOQCXKo/oaCZesJSN6hXbyORGkeSy8bk1FnT4pJaVOFnPWrvmGEcWFHuW6RF
XfYjyZBcUtTaAgnkjPfbluy2cRR9xwtbXt68Bj88Vg/qkeTzKbucE69vfC4J/BhM
LkjJI8rluofK6eP8fgTnHpQ7fXWjMglgS77d1pgoHXpK7AKRmT1WTIKFvJkfZAtF
aiqki1UtZYHIRt5aGt/rc1axbm25Fv4gFI4/d4v4Uhpi//JBWbfVrJO+I8Xs6rh/
z+EWye3aNHqzjIut7FYs
=g4wr
-----END PGP SIGNATURE-----

--R7UXdSL4eQSsawBSAX5tfaT5LFSLvLltB--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
