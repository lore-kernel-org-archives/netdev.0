From: Leon Romanovsky <leon@kernel.org>
Subject: Re: [RFC iproute2 0/8] RDMA tool
Date: Thu, 4 May 2017 21:25:42 +0300
Message-ID: <20170504182542.GD22833@mtr-leonro.local>
References: <20170504180216.7665-1-leon@kernel.org>
 <1493921453.2692.6.camel@sandisk.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="3dBJfKlFjfsS/piO"
Cc: "stephen@networkplumber.org" <stephen@networkplumber.org>,
        "dledford@redhat.com" <dledford@redhat.com>,
        "jiri@mellanox.com" <jiri@mellanox.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        "ram.amrani@cavium.com" <ram.amrani@cavium.com>,
        "sagi@grimberg.me" <sagi@grimberg.me>,
        "ogerlitz@mellanox.com" <ogerlitz@mellanox.com>,
        "dennis.dalessandro@intel.com" <dennis.dalessandro@intel.com>,
        "hch@lst.de" <hch@lst.de>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jgunthorpe@obsidianresearch.com" <jgunthorpe@obsidianresearch.com>,
        "ariela@mellanox.com" <ariela@mellanox.com>
To: Bart Van Assche <Bart.VanAssche@sandisk.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:33480 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756227AbdEDSZh (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 4 May 2017 14:25:37 -0400
Content-Disposition: inline
In-Reply-To: <1493921453.2692.6.camel@sandisk.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--3dBJfKlFjfsS/piO
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Thu, May 04, 2017 at 06:10:54PM +0000, Bart Van Assche wrote:
> On Thu, 2017-05-04 at 21:02 +0300, Leon Romanovsky wrote:
> > Following our discussion both in mailing list [1] and at the LPC 2016 [2],
> > we would like to propose this RDMA tool to be part of iproute2 package
> > and finally improve this situation.
>
> Hello Leon,
>
> Although I really appreciate your work: can you clarify why you would like to
> add *RDMA* functionality to an *IP routing* tool? I haven't found any motivation
> for adding RDMA functionality to iproute2 in [1].

We are planning to reuse the same infrastructure provided by iproute2,
like netlink parsing, access to distributions, same CLI and same standards.

Right now, RDMA is already tightened to netdev: iWARP, RoCE, IPoIB, HFI-VNIC.
Many drivers (mlx, qed, i40, cxgb) are sharing code between net and
RDMA.

I do expect that iproute2 will be installed on every machine with any
type of connection, including IB and OPA.

So I think that it is enough to be part of that suite and don't invent
our own for one specific tool.

Thanks

>
> Thanks,
>
> Bart.--
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--3dBJfKlFjfsS/piO
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkLciYACgkQ5GN7iDZy
WKc43Q/+NdnLNWr67QdCtoVyKZUJ8R5xyABnjG/kLM1dk6vMrTuLqLuB/s6YDg6X
HTHO4AFV3QWC7nsAtlaQfKA3UI26W4XQpwjATobw+W1ZLjPnWq9vSQsss3cLKd7w
8nomjC81to1RwYnifK+Q52kDeqY8qth1V7yF88vKgP0rElsBqn+/fRJGTIfeOLgI
ren5m3OqiTjftdjkh5qSFUzymuj4JZ3AkaFMVda8n6AFh9qlFGlAXnohNiESCpDw
sPTKeSMilDRylyDoj/0bK0v04AIf51LSCsZ6RG8SiH1Ly/CwtK21brjrwMHl6uCK
uxVgSv3xkud7s6AoY5jztsTADtvtM3Px8JFKfW25qb04qxlI4Cs+3gAm2lfRCMWC
cnXfMNNqzxSjz5ykDDP5Ovk+8p7rlqgZGfgbbKgb5mBYxid5vn3DO45tfP7YCpV/
gFDyp7WvcK8LlwUKo2tmh/apbXAuUSK0plHX5V6YOOf2f5Hpxi+IVxYgEWGjDoNp
iCLbFWupjp/EQuiPF8cA79X+56gvtjT6/HQ33zR2ToN4UqJ68LHR1rt9mjpC70h8
71ogD6IjIIrN+2Izk31z3gGIkzRd+HEO7wsiToVxR7iJAp53zvpCQr7Y2Kxf4r+R
3G14170g13oCQwGICxOO6Y1sWMjCy+K856AtKS657TZ8WjrIrvw=
=qpQA
-----END PGP SIGNATURE-----

--3dBJfKlFjfsS/piO--
