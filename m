From: "Liran Liss" <liranl-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
Subject: RE: [PATCH 19/25] mlx4: Randomizing mac addresses for slaves
Date: Thu, 5 Nov 2009 15:38:18 +0200
Message-ID: <2ED289D4E09FBD4D92D911E869B97FDD0166CA59@mtlexch01.mtl.com>
References: <4AF19E69.8070605@mellanox.co.il> <adar5seys3e.fsf@cisco.com> <15ddcffd0911041333l165ee274mfae3508a3db755e7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Yevgeny Petrilin" <yevgenyp-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>,
	<linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"Tziporet Koren" <tziporet-VPRAkNaXOzVS1MOuV/RT9w@public.gmane.org>
To: "Or Gerlitz" <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	"Roland Dreier" <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-class: urn:content-classes:message
In-reply-to: <15ddcffd0911041333l165ee274mfae3508a3db755e7-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This approach seems to be common practice now (e.g., drivers/net/igb/ig=
b_main.c:1332).
In any case, the user can change the randomized mac.
--Liran

-----Original Message-----
=46rom: Or Gerlitz [mailto:or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org]=20
Sent: Wednesday, November 04, 2009 11:33 PM
To: Roland Dreier
Cc: Yevgeny Petrilin; linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org; netdev-u79uwXL29TaqPxH82wqD4g@public.gmane.org=
g; Liran Liss; Tziporet Koren
Subject: Re: [PATCH 19/25] mlx4: Randomizing mac addresses for slaves

On Wed, Nov 4, 2009 at 10:04 PM, Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org> wrot=
e:
>> +#define MLX4_MAC_HEAD =A0 =A0 =A0 =A0 =A0 =A0 =A0 0x2c9000000ULL

> Is this a good idea? =A0You're basically choosing 24 random bits with=
in your OUI...
> seems the chance of collision with another MAC used on the same=20
> network is high enough that it could easily happen in practice on a m=
oderately big network.

yes, this has been brought by Stephen and others on this last back on S=
eptember 11th, this year @
http://marc.info/?l=3Dlinux-netdev&m=3D125263488409128

> Can you pick a reserved range or something?

Using different OUI for the VF device wouldn't help either I think, sin=
ce the #VF becomes fairly big even on a modest side cluster with
(say) a VM consuming VF per 1-2 cores.

Or.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
