From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: [PATCH 00/25] mlx4: multi-function framework and Ethernet sriov.
Date: Wed, 04 Nov 2009 17:30:09 +0200
Message-ID: <4AF19E01.1000305@mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org, tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org,
	yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org
To: rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


In ConnectX, nearly all device resources can be associated with any function.
Once allocated, these resources can be manipulated exclusively by their associated
functions in the same manner as in the single-function case.

The device continues to use a single HCA Command Register (HCR), which is owned by the pf.
Thus, the pf is given the role of allocating resources to vfs, and controlling shared
resource (such as ports).

A dedicated HW communication channel is used to transfer resource allocation and
modification requests from vfs to the pf, and events from the pf to the vfs.
Consequently, no hypervisor-specific services are required for pf-vf communication.

This patch set sets the ground for multi-function operation and enables Ethernet interfaces on vfs.

Signed-off-by: Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Signed-off-by: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
