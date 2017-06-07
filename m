From: Leon Romanovsky <leon@kernel.org>
Subject: Re: Netlink messages without NLM_F_REQUEST flag
Date: Wed, 7 Jun 2017 21:13:58 +0300
Message-ID: <20170607181358.GH1127@mtr-leonro.local>
References: <20170607161901.GD1127@mtr-leonro.local>
 <20170607163758.GA25313@obsidianresearch.com>
 <CALq1K=Jj_jJ5_OAiiws-es37tFEsLeLJeSvnU+bfwd0KLkGM3Q@mail.gmail.com>
 <20170607164750.GA7507@obsidianresearch.com>
 <20170607170037.GG1127@mtr-leonro.local>
 <2807E5FD2F6FDA4886F6618EAC48510E67CCE1CD@CRSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="6lXr1rPCNTf1w0X8"
Cc: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        "Wan, Kaike" <kaike.wan@intel.com>,
        "Fleck, John" <john.fleck@intel.com>, Thomas Graf <tgraf@suug.ch>,
        Doug Ledford <dledford@redhat.com>,
        Jiri Pirko <jiri@mellanox.com>,
        RDMA mailing list <linux-rdma@vger.kernel.org>,
        linux-netdev <netdev@vger.kernel.org>
To: "Weiny, Ira" <ira.weiny@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.99]:60474 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751584AbdFGSOF (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Jun 2017 14:14:05 -0400
Content-Disposition: inline
In-Reply-To: <2807E5FD2F6FDA4886F6618EAC48510E67CCE1CD@CRSMSX101.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--6lXr1rPCNTf1w0X8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 07, 2017 at 05:10:35PM +0000, Weiny, Ira wrote:
> >
> > On Wed, Jun 07, 2017 at 10:47:50AM -0600, Jason Gunthorpe wrote:
> > > On Wed, Jun 07, 2017 at 07:43:44PM +0300, Leon Romanovsky wrote:
> > > > On Wed, Jun 7, 2017 at 7:37 PM, Jason Gunthorpe
> > > > <jgunthorpe@obsidianresearch.com> wrote:
> > > > > On Wed, Jun 07, 2017 at 07:19:01PM +0300, Leon Romanovsky wrote:
> > > > >> It makes me wonder if it is expected behavior for
> > > > >> ibnl_rcv_reply_skb() to handle !NLM_F_REQUEST messages and do
> > > > >> we really need it? What are the scenarios?  In my use case,
> > > > >> which is for sure different from yours, I'm always setting
> > > > >> NLM_F_REQUEST while communicating with kernel.
> > > > >
> > > > > If I recall the user space SA code issues REQUESTS from the
> > > > > kernel to userspace, so userspace returns with the response
> > > > > format. This is abnormal for netlink hence the special function.
> > > >
> > > > In netlink semantics, kernel side is supposed to send netlink
> > > > notification message and userspace is supposed to send REQUEST.
> > >
> > > That pattern is for async communications, the SA stuff needs a sync
> > > protocol, unfortunately.
> >
> > There is special flag NLM_F_ACK for it and userspace will set
> > NLM_F_REQUEST | NLM_F_ACK once synchronization is needed.
> >
>
> Reference?
>
> From my understanding, NLM_F_REQUEST | NLM_F_ACK is simply requesting an ack from the kernel on a request.  In our case the message is a response to the kernel request.

There is a large chance that we are talking about different aspects of
"sync protocol" and for sure it is due to  my misunderstanding. Can you
elaborate more about the protocol? Why is so unique to RDMA?

Why is ACK + sequence number tracking not enough?

https://www.infradead.org/~tgr/libnl/doc/core.html#core_msg_ack

>
> Ira
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--6lXr1rPCNTf1w0X8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlk4QmYACgkQ5GN7iDZy
WKcuEBAAhy4lwPJMqNF/A2sLrkn97U+CgnT9d5nbv0B6WZcYmIopO5/O8VfbYxEo
7x4J8zqf8+6LAVrXvbpmRLp0TGwfzrUfCVI8hhiHnN9XQoUYGr5EaEuwT1os/zZd
0Ekk57UVWW1/ENIiXNR1DB+o9I/rVF7zi5G0evvDTOYpx/lJ6K1NTDeFtERZzoHE
LdB3tOlsvsbyjb8zwsJbXf7Pptl6MwE1wq7AsB1q/nEiEZiObkKpVAvAYDk+VNCs
OVKlYjnJPy68QBNXNI2Qn+DvGeyM+BL1PO1DnHLAKatV84/xlVdtYTuk2D/yZ9bi
+vXfLx0Kzi+nET/jD0gUahR/5dpbW2+c9WNyXWLf14ruv3Yl66a/PBGTS9+l09Sv
T7p+YW9ghPmJOBqDwajsMRApkksB624uPDsXgfoywR/LR4itNJlWbQ16z522HhSa
XDVPPqZ1qihrZ+JAH1tdP688QW8YY2BUk523Wv+wfO+gnNUY+JWa/FiYRDFGYd7a
LM0gwHk7VYTO06K7fK1czDD9EQv1szgSQncjyG4Re8QoLcB9p0jCy8kIZD4r6js4
nEdY5xkJuiYV43uRnPwRbpMRksblFZElVcDPb/n5hlMbHfH/PXmnsJhBqKAi5cOH
75rrGz1pNMBZJxncQoYCmTOdTaZkssc5fNngi/LrlzPg6682Bl0=
=jE3d
-----END PGP SIGNATURE-----

--6lXr1rPCNTf1w0X8--
