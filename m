From: "Hefty, Sean" <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: RE: [RFC 2/3] RDMA/cma: Add support for netlink statistics export
Date: Mon, 16 May 2011 15:08:13 +0000
Message-ID: <1828884A29C6694DAF28B7E6B8A82373F654@ORSMSX101.amr.corp.intel.com>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
	<1305303525-11113-3-git-send-email-roland@kernel.org>
 <1828884A29C6694DAF28B7E6B8A82373F428@ORSMSX101.amr.corp.intel.com>
 <4DD0DAB2.1080600@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4DD0DAB2.1080600-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

> Isn't the port space enough here? specifically, what qp type buys us
> over port space?

That assumes a 1:1 relationship between the port space and QP type, or more specifically, that the IB SID range is divided based on QP type.  This is outside of the architecture.  If we look at UC or XRC, it's not clear what port space those map to, but I believe it's desirable for the rdma_cm to support those.  Note that the AF_IB patch set ended up requiring that the user specify the qp type for these reasons.

- Sean
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
