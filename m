From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: RCU'ed dst_get_neighbour()
Date: Wed, 30 Nov 2011 00:25:43 +0100
Message-ID: <1322609143.2596.54.camel@edumazet-laptop>
References: <1322606542.2596.43.camel@edumazet-laptop>
	 <alpine.WNT.2.00.1111291600220.228@TSI>
	 <1322608261.2596.48.camel@edumazet-laptop>
	 <20111129.182441.956675970003939556.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: tsi-yfeSBMgouQgsA/PxXw9srA@public.gmane.org, roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20111129.182441.956675970003939556.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Le mardi 29 novembre 2011 =C3=A0 18:24 -0500, David Miller a =C3=A9crit=
 :
> From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Wed, 30 Nov 2011 00:11:01 +0100
>=20
> > For example, recently added skb_update_prio() is buggy, since it us=
es
> > rcu_dereference() while its caller, dev_queue_xmit() called
> > rcu_read_lock_bh()
>=20
> We have a fixed queued up for that from Igor, I'll apply that right n=
ow.

OK, fine :)


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
