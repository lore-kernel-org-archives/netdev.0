From: "Yevgeny Petrilin" <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: RE: [PATCH 08/25] mlx4_core: fix buggy parsing of reserved eq cap
Date: Thu, 5 Nov 2009 22:09:30 +0200
Message-ID: <2ED289D4E09FBD4D92D911E869B97FDD0166CEF4@mtlexch01.mtl.com>
References: <4AF19E2C.6060604@mellanox.co.il> <adaws2468tq.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Liran Liss" <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	"Tziporet Koren" <tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: "Roland Dreier" <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-reply-to: <adaws2468tq.fsf-BjVyx320WGW9gfZ95n9DRSW4+XlvGpQz@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

 

> > -	dev_cap->reserved_eqs = 1 << (field & 0xf);
> > +	dev_cap->reserved_eqs = field & 0xf;
>
>This patch looks good to apply right now.  Is it OK for me to make this
>"From: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>" and add "Signed-off-by:
>Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>"?

Yes, but
I am currently working on fixing the patches according to comments
received so far,
And thought to resubmit the entire patch set.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
