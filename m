From: Yevgeny Petrilin <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: RE: [PATCH 01/25 v2] mlx4_core: identify function as pf or vf
Date: Tue, 26 Jan 2010 10:21:30 +0200
Message-ID: <E113D394D7C5DB4F8FF691FA7EE9DB44384E3CAC3F@MTLMAIL.mtl.com>
References: <4AF3930E.90904@mellanox.co.il>
 <adar5peouu3.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Liran Liss <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	Tziporet Koren <tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <adar5peouu3.fsf-BjVyx320WGW9gfZ95n9DRSW4+XlvGpQz@public.gmane.org>
Content-Language: en-US
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


> I'm a bit confused by these flags.  As far as I can tell, the SRIOV flag will be set if and > only if MASTER is set too... so in other words we might as well just have the MASTER and > > SLAVE flags and not have the SRIOV flag at all.

We could have a situation where we have multiple physical functions, without SRIOV.
In this case one of the functions would be MASTER, but not SRIOV

Yevgeny

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
