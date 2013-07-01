From: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH for-next 0/8] Add Mellanox mlx5 driver for Connect-IB
 devices
Date: Mon, 01 Jul 2013 14:53:00 -0700
Message-ID: <1372715580.2481.34.camel@joe-AO722>
References: <1371384149-24558-1-git-send-email-eli@dev.mellanox.co.il>
	 <CAJZOPZ+NQa3CWnw3rZQh2UuwdrNhiwtVSyuk9D9YtwfQQ9e1XA@mail.gmail.com>
	 <CAJZOPZKLb9k1xXkTnrtzYKpwrSJDQgBpONUVCp3et36JeaEi-Q@mail.gmail.com>
	 <CAL1RGDX5mHj5oVqFhQ4Ssr25jpL4rV2Tv=zXvLOZfwupJ0gqJw@mail.gmail.com>
	 <1372701839.2481.3.camel@joe-AO722>
	 <CAL1RGDW_Z06ZqpOhz3tAkKn=rpLEZE6hWZkLNd9OQgCbrX6YAg@mail.gmail.com>
	 <1372709942.2481.13.camel@joe-AO722>
	 <CAL1RGDVgSucpRhyxBZDVeLO+Q+Y7HuPsDjUy6kaFMoL3E8s77g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <or.gerlitz-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Eli Cohen <eli-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>,
	"linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDVgSucpRhyxBZDVeLO+Q+Y7HuPsDjUy6kaFMoL3E8s77g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-07-01 at 14:20 -0700, Roland Dreier wrote:
> On Mon, Jul 1, 2013 at 1:19 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> > I think these are the groupings.
> >
> > +enum {
> > +       MLX5_MOD_MAIN,
> > +       MLX5_MOD_CMDIF,
> > +       MLX5_MOD_EQ,
> > +       MLX5_MOD_QP,
> > +       MLX5_MOD_PGALLOC,
> > +       MLX5_MOD_FW,
> > +       MLX5_MOD_UAR,
> > +       MLX5_MOD_ALLOC,
> > +       MLX5_MOD_DEBUG,
> > +       MLX5_MOD_HEALTH,
> > +       MLX5_MOD_MAD,
> > +       MLX5_MOD_MCG,
> > +       MLX5_MOD_MR,
> > +       MLX5_MOD_PD,
> > +       MLX5_MOD_PORT,
> > +       MLX5_MOD_SRQ,
> > +       MLX5_MOD_CQ,
> > +       MLX5_MOD_CMD_DATA, /* print command payload only */
> > +       MLX5_CMD_DATA_TIME,
> > +};
> 
> 
> Right, but then look how they're used.  For example,
> drivers/net/ethernet/mellanox/mlx5/core/main.c has:
> 
>     MLX5_MOD_DBG_MASK(MLX5_MOD_MAIN);
> 
> so MLX5_MOD_MAIN just means messages in main.c, etc.

Thanks.  OK, yeah, that's completely unnecessary.
Just using dynamic_debug is far better.


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
