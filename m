From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH] net/mlx5e: avoid stack overflow in mlx5e_open_channels
Date: Tue, 26 Apr 2016 15:53:40 +0200
Message-ID: <5940636.9Nic57IXcZ@wuerfel>
References: <1461590139-1396745-1-git-send-email-arnd@arndb.de> <CALzJLG98swFRKAZUcoXMWMyzX3z_h-HhTNZD_unh43VHByZY0A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Achiad Shochat <achiad-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Amir Vadai <amir-IB5XiEnQfqI@public.gmane.org>,
	Tariq Toukan <tariqt-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG98swFRKAZUcoXMWMyzX3z_h-HhTNZD_unh43VHByZY0A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tuesday 26 April 2016 16:48:33 Saeed Mahameed wrote:
> >  }
> >
> > -static void mlx5e_build_channel_param(struct mlx5e_priv *priv,
> > -                                     struct mlx5e_channel_param *cparam)
> > +static struct mlx5e_channel_param *mlx5e_build_channel_param(struct mlx5e_priv *priv)
> 
> I prefer to keep the function prototype as before and move the dynamic
> allocation to mlx5e_open_channels,
> to keep alloc/free symmetric in mlx5e_open_channels.
> 
> 

Sure, do you want to just edit this when you forward the patch, or
do you need me to do it?

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
