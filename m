From: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [RFC 2/3] RDMA/cma: Add support for netlink statistics export
Date: Mon, 16 May 2011 22:13:05 +0300
Message-ID: <BANLkTimD9PvyrKYMEPDii-pQGd4Y70vrNQ@mail.gmail.com>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
	<1305303525-11113-3-git-send-email-roland@kernel.org>
	<1828884A29C6694DAF28B7E6B8A82373F428@ORSMSX101.amr.corp.intel.com>
	<4DD0DAB2.1080600@mellanox.com>
	<1828884A29C6694DAF28B7E6B8A82373F654@ORSMSX101.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1828884A29C6694DAF28B7E6B8A82373F654-P5GAC/sN6hmkrb+BlOpmy7fspsVTdybXVpNB7YpNyf8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hefty, Sean <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org> wrote:

> That assumes a 1:1 relationship between the port space and QP type, o=
r more
> specifically, that the IB SID range is divided based on QP type. =A0T=
his is outside of the
> architecture. =A0If we look at UC or XRC, it's not clear what port sp=
ace those map to, but I
> believe it's desirable for the rdma_cm to support those.

makes sense, so we can add the qp type here.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
