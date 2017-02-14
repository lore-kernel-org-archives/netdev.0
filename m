From: Doug Ledford <dledford@redhat.com>
Subject: Re: [PATCH V5 for-next 00/21] Broadcom RoCE Driver (bnxt_re)
Date: Tue, 14 Feb 2017 09:59:31 -0500
Message-ID: <1487084371.86943.68.camel@redhat.com>
References: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-/acA9NqDkbT3Va4wfR51"
Cc: netdev@vger.kernel.org
To: Selvin Xavier <selvin.xavier@broadcom.com>,
        linux-rdma@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:33652 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753109AbdBNO7d (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 14 Feb 2017 09:59:33 -0500
In-Reply-To: <1486725593-9872-1-git-send-email-selvin.xavier@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-/acA9NqDkbT3Va4wfR51
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Fri, 2017-02-10 at 03:19 -0800, Selvin Xavier wrote:
> This series introduces the RoCE driver for the Broadcom
> NetXtreme-E 10/25/40/50G RoCE HCAs.
> This driver is dependent on the bnxt_en NIC driver and is
> based on the for-4.11 branch in linux-rdma repository.
> bnxt_en changes required for this patch series are already
> available afore mentioned branch.
>=20
> These changes are available for your reference in
> the bnxt_re_v5 branch of following repository.
> https://github.com/Broadcom/linux-rdma-nxt/
>=20
> Doug,
> This patchset addresses review comments from you and Leon.
> This series also includes some changes required for the latest FW.
> Please consider applying this to linux-rdma tree.

Thanks, v5 applied. =C2=A0I squashed it down to just two commits: 1 to add
the driver itself, and 1 that only adds the build makefiles. =C2=A0I've
pushed it to github so far, I'll push it to k.o once I get 0day build
tests back on it. =C2=A0Feel free to look it over on github if you want to
see how it came out after the squashing and such.

--=20
Doug Ledford <dledford@redhat.com>
=C2=A0 =C2=A0 GPG KeyID: B826A3330E572FDD
=C2=A0 =C2=A0
Key fingerprint =3D AE6B 1BDA 122B 23B4 265B =C2=A01274 B826 A333 0E57 2FDD

--=-/acA9NqDkbT3Va4wfR51
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCAAGBQJYoxtTAAoJELgmozMOVy/df/UQAMS5VtKC3vbH4pHUl5OiZ4QD
W7EDwhOdfMOtZ3lb1xc2W2hgOScwGOqDpbvUQkmerK4Hfke4ZZZmgnHFQhVkdbxl
isqsFA7oNdn64B/Xm1GyroBWNYJvYwtoGh74s9oHyqOatlrz80q/7JMq9+gMXn+7
gxpzhgLwGuLKfIrpkvMPg8+AcKLaWHBwVtYlJwjgr3ImMqhBEFr6zPKD4pyMv9u3
t1SsTI3+MIYgWpCI02UFCzDVSIgKKZYNDLhyBAFnvQwwuJyG89wqojnfeL58BiZw
jGuJs7bB6Q8V2fMPMjgwOtdtgUr+5VpN9BfTOniwoXFcidlCr51QCTu1BLQC8V/O
J07/RbxinIRB0pYxphAceF8mBZ48tc47J1emnfCpTXfMMhJqRZGR9b7EYyJfZQE2
fZG1HSHkU7kRx5CrMEDh7mhxvSqXBV0fZhtsWbdP0I7YUwkkJi3EFGx70qBH6Lmw
rY2ivH0T6fAjQ6a4WP4+S97hJRKVDv0q6XyV6NzS967EwN3mTgsqAhnjkq/mKSCp
3TBSrjd1YprohPZxnIrDwH9YuhTkJmaL5Pv56BYXWSryZQdBp/YHNJiGn89ZLdb9
Ac0Ge1JJ2IVnFsOfkuBeSzvyiB5jYQWRiFs3RnZFWk6WldCt5nnfl2szdmm/p6qr
uZWV4j7PPUJo60udh5Rw
=nera
-----END PGP SIGNATURE-----

--=-/acA9NqDkbT3Va4wfR51--
