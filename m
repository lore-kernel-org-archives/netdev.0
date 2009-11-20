From: Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH] RDMA/addr: Use appropriate locking with for_each_netdev()
Date: Fri, 20 Nov 2009 07:51:36 +0100
Message-ID: <4B063C78.1070502@gmail.com>
References: <4AF8EBA4.2070102@gmail.com>	<D5E1FB213939498DBFFEB5A3B83C08AD@amr.corp.intel.com>	<adaocn8x6j7.fsf@roland-alpha.cisco.com>	<8C10E584257A46DB9A0AD193520CF4A7@amr.corp.intel.com>	<4B0628E0.6000404@gmail.com> <adak4xl669z.fsf@roland-alpha.cisco.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Sean Hefty <sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Roland Dreier <rolandd-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>,
	Hal Rosenstock <hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <rdreier-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <adak4xl669z.fsf-BjVyx320WGW9gfZ95n9DRSW4+XlvGpQz@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Roland Dreier a =E9crit :
>  > Any news of this patch ?
>  >=20
>  > We need it for 2.6.32 and also to prepare 2.6.33 with upcoming pat=
ches.
>=20
> Sorry for not explicitly emailing about this patch.  I applied it as
> part of Sean's series, but I just added it to my 2.6.33 queue.  At th=
is
> point in the release cycle it doesn't look severe enough for 2.6.32,
> unless I miss something.

Its possible to get infinite loops or crashes.

I am not a RDMA user, so I personally dont care :)

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
