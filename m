From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [RFC] [PATCH] net: socket: Fix the wrong returns for recvmsg
 and sendmsg
Date: Sat, 01 Aug 2015 20:36:22 +0100
Message-ID: <1438457782.3225.35.camel@decadent.org.uk>
References: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-tNZ0fBS4rdOwby5/TyNT"
Cc: lizefan@huawei.com, viro@zeniv.linux.org.uk, davem@davemloft.net,
	xuhanbing@huawei.com, stable@vger.kernel.org,
	netdev@vger.kernel.org
To: Junling Zheng <zhengjunling@huawei.com>, gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:35124 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751373AbbHATgi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Aug 2015 15:36:38 -0400
In-Reply-To: <1433150880-9976-1-git-send-email-zhengjunling@huawei.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-tNZ0fBS4rdOwby5/TyNT
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Mon, 2015-06-01 at 09:28 +0000, Junling Zheng wrote:
> Hi, Greg:
>=20
> We found that after v3.10.73, recvmsg might return -EFAULT while -EINVAL
> was expected.
>=20
> We tested it through the recvmsg01 testcase come from LTP testsuit. It se=
t
> msg->msg_namelen to -1 and the recvmsg syscall returned errno 14, which i=
s
> unexpected (errno 22 is expected):
>=20
> recvmsg01    4  TFAIL  :  invalid socket length ; returned -1 (expected -=
1),
> errno 14 (expected 22)
>=20
> Linux mainline has no this bug for commit 08adb7dab fixes it accidentally=
.
> However, it is too large and complex to be backported to LTS 3.10.
>=20
> So, I made the following patch to fix the above problem for LTS 3.10.
[...]

It looks like the 3.2 branch has the same problem, so I've queued this
patch up there as well.  Thanks a lot.

Ben.

--=20
Ben Hutchings
One of the nice things about standards is that there are so many of them.


--=-tNZ0fBS4rdOwby5/TyNT
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIVAwUAVb0ftue/yOyVhhEJAQrdHBAAuZpxA6HCIAkvm9zADRszP+Uz6E9AjWNi
9665Gay9UEEeRdqzF65SG+TETGDrvp7lA00/wnwE5BrROrEDyRzbozvDAXJeotyu
5MelxcEBhO191SSY66Px7U0sCSJKtuB+N53T8ORp3AtG/cWGwGGAf/7V6MUuFTYf
FAhxtTSbhkmBO44AhN0WG7w3SPjgiF0RunT7UXlZH6SH7sqSCGUxbqZqH1LLLYpD
dV5DUwMBeXWBwdCyUXPAQHA6h2bsnownNgw4J2ZdKl5L1mRgiQhHEe/4MAIK+aGt
JOjK2SCLUlwp/PlWuavAs0E4neJJzqxt/493pTG8igD9mAB4FUB8sZRt4ipi7QCt
rrnlCabcfkEdM7mwp3bqCJCnvMkg1PVXYMxFSBNy8jOM5Bb6zOKPW3sblq58PjIn
UfpJKVogS1Vh3LeeSCEDeGMfYIqQXx634Mmbf91ZC1+jx0+t3RjdEeAZrS4L2Wf/
yAHY0auXt8YnrpQ1ODOdADpqsTfsVNJkD6JGkebm990KJyDW9JykTqVNs5v7Cb2g
HkLZBrz400eXz59MifBiCGcsk+ILGZqDDCWcDX3t54tkWafLxxCO0pF3wgM6+RfR
vRq8yn4xA603RBPLS+jh5hGH76010waT30e7Znj69D9SLVmmeD9oCDJQ+XD9WGt0
tZoboHC4B8w=
=/4Z2
-----END PGP SIGNATURE-----

--=-tNZ0fBS4rdOwby5/TyNT--
