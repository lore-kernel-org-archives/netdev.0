From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 03/25] mlx4_core: add multi-function communicationchannel
Date: Thu, 05 Nov 2009 10:01:17 -0800
Message-ID: <adatyx8c0lu.fsf@roland-alpha.cisco.com>
References: <4AF19E14.5070107@mellanox.co.il> <adaiqdq17zo.fsf@cisco.com>
	<2ED289D4E09FBD4D92D911E869B97FDD0166C9B7@mtlexch01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Yevgeny Petrilin" <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Tziporet Koren" <tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: "Liran Liss" <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2ED289D4E09FBD4D92D911E869B97FDD0166C9B7-ia22CT07NJfiMCgWhms8HQC/G2K4zDHf@public.gmane.org>
	(Liran Liss's message of "Thu, 5 Nov 2009 15:06:58 +0200")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


 > > And HZ/1000 is going to be 0 if HZ is less than 1000 ... so this is just
 > > going to run continuously in the polling case.

 > This is what we want as long as there are more pending commands.

So then instead of HZ/1000 just use 0 always?  I don't see a reason why
you would want to wait if HZ >= 1000 and not wait if HZ is < 1000.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
