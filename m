From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH V3 for-next 00/11] Code improvements & fixes for HNS RoCE
 driver
Date: Mon, 12 Dec 2016 17:09:09 -0500
Message-ID: <26851a7d-08bf-74b4-2c0c-3d519a30b9b2@redhat.com>
References: <20161123194109.420760-1-salil.mehta@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
 protocol="application/pgp-signature";
 boundary="MDuUEFpLaFQhRGfVaNeKV60KMxMVW8NIv"
Cc: xavier.huwei@huawei.com, oulijun@huawei.com, xushaobo2@huawei.com,
        mehta.salil.lnk@gmail.com, lijun_nudt@163.com,
        linux-rdma@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, linuxarm@huawei.com
To: Salil Mehta <salil.mehta@huawei.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20161123194109.420760-1-salil.mehta@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--MDuUEFpLaFQhRGfVaNeKV60KMxMVW8NIv
Content-Type: multipart/mixed; boundary="FwNUhCMVpRtasjI1lLJCQkS3Fq7ArspX4";
 protected-headers="v1"
From: Doug Ledford <dledford@redhat.com>
To: Salil Mehta <salil.mehta@huawei.com>
Cc: xavier.huwei@huawei.com, oulijun@huawei.com, xushaobo2@huawei.com,
 mehta.salil.lnk@gmail.com, lijun_nudt@163.com, linux-rdma@vger.kernel.org,
 netdev@vger.kernel.org, linux-kernel@vger.kernel.org, linuxarm@huawei.com
Message-ID: <26851a7d-08bf-74b4-2c0c-3d519a30b9b2@redhat.com>
Subject: Re: [PATCH V3 for-next 00/11] Code improvements & fixes for HNS RoCE
 driver
References: <20161123194109.420760-1-salil.mehta@huawei.com>
In-Reply-To: <20161123194109.420760-1-salil.mehta@huawei.com>

--FwNUhCMVpRtasjI1lLJCQkS3Fq7ArspX4
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: quoted-printable

On 11/23/2016 2:40 PM, Salil Mehta wrote:
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
>  drivers/infiniband/hw/hns/hns_roce_mr.c     |   22 +-
>  drivers/infiniband/hw/hns/hns_roce_pd.c     |    5 +-
>  drivers/infiniband/hw/hns/hns_roce_qp.c     |    2 +-
>  14 files changed, 364 insertions(+), 362 deletions(-)
>=20

Series applied, thanks.

--=20
Doug Ledford <dledford@redhat.com>
    GPG Key ID: 0E572FDD


--FwNUhCMVpRtasjI1lLJCQkS3Fq7ArspX4--

--MDuUEFpLaFQhRGfVaNeKV60KMxMVW8NIv
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQIcBAEBCAAGBQJYTyAFAAoJELgmozMOVy/dlc4QAJxMq8Vm0KPx4a4D+qSgrAqx
Jr8MiFZPFOVUqtng6Qr3tZrRHSFxlHK0KSAAXun3+ZRm7R2ltHz0OrkkyvGyOV67
4KXY10yGcBlHIx69bT/84UBmiJYaAhFYGdtpVCFpZF7uX7fMZRAYXwcdU+Az2am3
VDjcaXZ92S7ATfLsCsRCvnedf9KDmFKuBMESU3jWQ/QQCdeXBYABTIRW40PNrlMF
MzoDUISHQUG97NH4tu0N5OBR06iU4ZQYvvDXPbG+970vOwS+/JJ0jP+ptZ+kkj3m
cJH5mNB501ObSY61r6pUmwAOAMs2Unltf/h3KwsVuO3ZElieaGPIbuSTZ4ECY2Tv
+DjCn6l2JhM6c+gbyBfL+qjju2zuZTVP7icue1/amjPW4MEca0OZMEuKE0rfcCYp
QhzPGQUjEaUwOf3eRHTRRD7AUBaB+hJEIHZw1InDVFWXAk7HSWBb+25Lg/QFQz++
937691LOldnZxd1aVHVV17atJbgVgpfO/pkjBwlc4P8SKD98c9Rm1kBK/gT4sJC5
8E1ZWFAxecdBkecHK7ogMRHGYCjDbkM5aMsv9YJ1OGzCMXC8FPSUWLdp2VXYyOjt
4LRYYzkrMhA8Kat2PlZD7kMiJqe72ydWVwt/M0gDLa7lLDbZZwYxV6jL7+cpQ94W
R0nLj8mNPobLP0vQssFi
=gO/S
-----END PGP SIGNATURE-----

--MDuUEFpLaFQhRGfVaNeKV60KMxMVW8NIv--
