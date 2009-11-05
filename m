From: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH 19/25] mlx4: Randomizing mac addresses for slaves
Date: Thu, 05 Nov 2009 07:58:12 -0800
Message-ID: <adabpjhc6az.fsf@roland-alpha.cisco.com>
References: <4AF19E69.8070605@mellanox.co.il> <adar5seys3e.fsf@cisco.com>
	<15ddcffd0911041333l165ee274mfae3508a3db755e7@mail.gmail.com>
	<2ED289D4E09FBD4D92D911E869B97FDD0166CA59@mtlexch01.mtl.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "Or Gerlitz" <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Yevgeny Petrilin" <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Tziporet Koren" <tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: "Liran Liss" <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2ED289D4E09FBD4D92D911E869B97FDD0166CA59-ia22CT07NJfiMCgWhms8HQC/G2K4zDHf@public.gmane.org>
	(Liran Liss's message of "Thu, 5 Nov 2009 15:38:18 +0200")
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


 > This approach seems to be common practice now (e.g., drivers/net/igb/igb_main.c:1332).
 > In any case, the user can change the randomized mac.

igb uses the full output of random_ether_addr().  I'd be fine with
that.  However setting the OUI means you only get 24 bits of randomness
which makes a collision a lot more likely.

 - R.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
