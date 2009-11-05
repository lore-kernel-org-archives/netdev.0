From: "Liran Liss" <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: RE: [PATCH 05/25] mlx4_core: add slave resource allocation
Date: Thu, 5 Nov 2009 15:14:46 +0200
Message-ID: <2ED289D4E09FBD4D92D911E869B97FDD0166C9D6@mtlexch01.mtl.com>
References: <4AF19E1E.4000102@mellanox.co.il> <ada7hu617aw.fsf@cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Tziporet Koren" <tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: "Roland Dreier" <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	"Yevgeny Petrilin" <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-reply-to: <ada7hu617aw.fsf-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 > +	u32 param1 = *((u32 *) &vhcr->in_param);
 > +	u32 param2 = *(((u32 *) &vhcr->in_param) + 1);

Is this endian clean?

LL: Yes - the master and slave always run on the same arch...

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
