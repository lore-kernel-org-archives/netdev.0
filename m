From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Wed, 18 Jan 2017 19:33:27 +0200
Message-ID: <20170118173327.GF32481@mtr-leonro.local>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
 <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="8f0Rp8CLSOFvlIcd"
Cc: Ariel Almog <arielalmogworkemails@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:43074 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751085AbdARRda (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 12:33:30 -0500
Content-Disposition: inline
In-Reply-To: <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--8f0Rp8CLSOFvlIcd
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Jan 18, 2017 at 06:48:21PM +0200, Or Gerlitz wrote:
> On Wed, Jan 18, 2017 at 5:19 PM, Ariel Almog
> <arielalmogworkemails@gmail.com> wrote:
> > General
> > *******
> > As of today, there is no single, simple, tool that allows monitoring
> > and configuration of RDMA stack.
>
> Before tool, what kernel UAPI you thought to use?

I'm aware of the following options:
1) netlink
2) RDMA ABI https://www.spinics.net/lists/linux-rdma/msg43960.html
3) ioctl
4) write/read

The items 1 and 2 are preferred options and one of the main goals
for this RFC is to chose between them.

For example, RDMA ABI has native support of querying and discovering
device capabilities via merge tree feature.
https://github.com/matanb10/linux/commit/61aaa4cae1281f6bb32e261f0b8aad489d=
b764ac

>
>
> > rdmatool will provide standard, provider agnostic, user interface.
> > RDMA user can use this interface to
> > * Query RDMA device capabilities
> > * Query RDMA device status and current open resources
> > * Fetching RDMA statistics
> > * Configure RDMA device
> >
> > The rdmatool will have the ability to control RDMA stack which
> > includes the ib_device and RDMA protocol params.
> >
> > It is a good point to highlight the similarity to ethtool. It manages
> > net_device, while rdmatool will manage RDMA stack.
> >
> > As a proposal, it is appealing to have a similar design to ethtool for
> > rdmatool too. As ethtool, it should contain user space part, kernel
> > handler and vendor specific handler(s).
> >
> > Another tool which allows similar functionality is iproute2. Iproute2
> > allows user space tools to configure and query transport, network and
> > link layer. The advantages of using iproute2 is the reuse of existing
> > tool and familiar interface in addition to the wide spreading of this t=
ool.
> >
> > As start point of the discussion, we would like to propose two
> > implementation options for the rdmatool:
> > (1) Build a tool using ABI interface. This will be a RDMA tool
> >     which will be distributed as part of RDMA package
> > (2) Enhancing iproute2 to include rdmatool functionality
> >
> > Our opinion is that the new ABI interface provides vast functionality a=
nd
> > it will be a waste to use other interface for the same functionality.
> > Each of the proposed implementation above have their advantages, and we
> > would like to hear your opinion regarding this direction.
>
> > I=E2=80=99m posting this RFC in both netdev and linux-rdma communities =
in
> > order to get feedback on this topic.
>
> What's wrong with the RDMA netlink infrastructure?! it's there for
> years and used
> for various cases by MLNX, did you look on the code?

Nothing wrong, it is one of the valuable options and will be used if
community decides to put this tool under iproute2/ethtool umbrella.

>
> cea05ea IB/core: Add flow control to the portmapper netlink calls
> ae43f82 IB/core: Add IP to GID netlink offload
> 2ca546b IB/sa: Route SA pathrecord query through netlink
> 753f618 RDMA/cma: Add support for netlink statistics export
> b2cbae2 RDMA: Add netlink infrastructure

--8f0Rp8CLSOFvlIcd
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlh/pucACgkQ5GN7iDZy
WKdSKBAAwEs94rH29acDkcIohq61wXf1YetwHWOYjQ/4xCfGwgJMAxl0VCmz3zpy
aADukMy0rlWY3/lF6sg/XN0oMM8lwPNKqYRgZ9/RnUIU8A2TfRWKkLO+efe9n/yd
6s+PP1LRz2N1jPVHx50GV9flK2wF4PcjJvSaQi7bZKOkFKfG8N2qpNmCbrcKEqf0
DrbvjrRI42wer/BJruC37YjErIqPY5m5mEtNslvb9CpxYfdrSI3Op3VObbhLhDjB
y4wjzakga3ooTNRmg2D/u/8JL2wAf99sKdweOTAdS3dpZk/JHrG3gGKnvJLaDiN/
xbyBsRNPUu0HekdiyXswW+6/STFSkHWmlvwhNJTbFFN2e7xjKL8KNG/sxdEu9LE2
C8ewrFPDDHS8+3xshOKCJ4KWqPiSF7XjormSdzIAtjvFw5HvfLyKYvFuWSaJs+6y
MfFcm0kcvcdKb9rl6FNvAkC2+ncc8g79U2sdc5PjW2Abk0lbFekNufgJlBXaOpJy
pk/DAJ4fauwJE2wDik3yxqWHRP61WzQmYZTX8kq9vpUpf6NJQVji7D2ISU5QdWtH
UjR3c3ev7E44l9zEU+Tz+cgH166H1pfdjz3pBUFRFRcfqAzVriWBNH1vKUFD/YuK
ZGtJlHTJq5NxycIXch8CFeSg+4/LC2CFuXpKKF8Mdya+A57poSY=
=woOQ
-----END PGP SIGNATURE-----

--8f0Rp8CLSOFvlIcd--
