From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 16/25] mlx4_core: boot sriov
Date: Thu, 05 Nov 2009 07:57:05 -0800
Message-ID: <adafx8tc6cu.fsf@roland-alpha.cisco.com>
References: <4AF19E5D.1060806@mellanox.co.il> <aday6mmyshm.fsf@cisco.com>
	<2ED289D4E09FBD4D92D911E869B97FDD0166CA13@mtlexch01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yevgeny Petrilin" <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Tziporet Koren" <tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: "Liran Liss" <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2ED289D4E09FBD4D92D911E869B97FDD0166CA13-ia22CT07NJfiMCgWhms8HQC/G2K4zDHf@public.gmane.org>
	(Liran Liss's message of "Thu, 5 Nov 2009 15:26:17 +0200")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


 > LL: I think that this won't pass -Wall when compiling against a kernel
 > with sriov compiled out.

Why not?  The sriov code provides stubs like:

static inline int pci_enable_sriov(struct pci_dev *dev, int nr_virtfn)
{
	return -ENODEV;
}

if CONFIG_PCI_IOV is not enabled.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
