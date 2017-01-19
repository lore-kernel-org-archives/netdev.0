From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Thu, 19 Jan 2017 08:04:27 +0200
Message-ID: <20170119060427.GI32481@mtr-leonro.local>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
 <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
 <20170118173327.GF32481@mtr-leonro.local>
 <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="Fhv9pqL4KIX+q4y7"
Cc: Ariel Almog <arielalmogworkemails@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:49240 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750765AbdASGOw (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 19 Jan 2017 01:14:52 -0500
Content-Disposition: inline
In-Reply-To: <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--Fhv9pqL4KIX+q4y7
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jan 18, 2017 at 07:50:26PM +0200, Or Gerlitz wrote:
> On Wed, Jan 18, 2017 at 7:33 PM, Leon Romanovsky wrote:
> > On Wed, Jan 18, 2017 at 06:48:21PM +0200, Or Gerlitz wrote:
> >> On Wed, Jan 18, 2017 at 5:19 PM, Ariel Almog
> >> <arielalmogworkemails@gmail.com> wrote:
>
> >> What's wrong with the RDMA netlink infrastructure?! it's there for
> >> years and used
> >> for various cases by MLNX, did you look on the code?
>
> > Nothing wrong, it is one of the valuable options and will be used if
> > community decides to put this tool under iproute2/ethtool umbrella.
>
> yeah, using netlink sounds good to me, and where you package/maintain
> the tool is of 2nd order, 1st decide what UAPI you wonna use. So far
> netlink was good for what bunch of use-cases needed.

Or,
This tool is for users and they don't care how it is implemented
underneath. We want to provide to our users similar experience as they
have already with other tools and package/maintainability is important
for them more than kernel UAPI.

Ariel came with a small set of initial functionalities, but it doesn't
say we should limit ourselves.

>
> Or.
>
> >> cea05ea IB/core: Add flow control to the portmapper netlink calls
> >> ae43f82 IB/core: Add IP to GID netlink offload
> >> 2ca546b IB/sa: Route SA pathrecord query through netlink
> >> 753f618 RDMA/cma: Add support for netlink statistics export
> >> b2cbae2 RDMA: Add netlink infrastructure
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--Fhv9pqL4KIX+q4y7
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAliAVusACgkQ5GN7iDZy
WKecxA/+KM8IWgBjL7soNbm5+/QxbElo1KcJuZBr0CNDzBGeCAxlaPEti7VmaSs0
iZkxFvBPJ2HZCLOKscqBSdZOZXGvLH1sLjMTSJJcrlsDxV2hZDSqKB5+0n7pN2rU
UcSDhG/Zjze5zkMvWz/gzkLmpd2beK2D0a8CZEuBopPOD/BLeBq+tFEWp6R/RFwb
cfUgwvkZDVqiaAHr0xesfzNWMauwirDXX3CJnD0vCA4q1AWHJebKhP1IIRbBfGzC
NfUBqelN0E6B/EW9KjRT3Q33jAaUbDFtdfcN57Y1CfByXLVKe9rnxSegSUmLZfRe
+DZsM8h2grJG70Mm8NCff6XqzypmT0KLiNecSXy6Hkf6ONmIT4Bpk/4LlPbnjE32
7vNdeajBDE/2CKx3p//RNarnkGq/rJ9t7Zg2pgeK92dwphn7ZgvvGDbCb+wyl8rv
/aBWB3itDzPblWMcangGWduVafIX9Dqg5v1jJXcIZzDhJ3f+6PQiQg1a1GFk5iXR
BTVgRILVTAiSulUD6v6G8xV6i/6DQzz53DxkOppkGFlItsgJIdAZddZPJIyMfvhr
h03NmBufxwF18btSyCGpUIZJtt0ZLB/qQd2VneoYsUqgnwdi6U1kxPsGdCgfkN0y
zzuYDiLdtpzkmg7QYI3kB+FZOnfP/GphMOqMIeN3c+QzXFgpB+s=
=ycvt
-----END PGP SIGNATURE-----

--Fhv9pqL4KIX+q4y7--
