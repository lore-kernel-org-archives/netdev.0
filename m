From: Arnd Bergmann <arnd-r2nGTMty4D4@public.gmane.org>
Subject: Re: [PATCH 1/2] mlx5: only register devlink when ethernet is available
Date: Wed, 15 Jun 2016 22:50:37 +0200
Message-ID: <6330398.ySWGKSmLdn@wuerfel>
References: <20160615152816.2800830-1-arnd@arndb.de> <CALzJLG_CkvbrCehMjMht5KfMK6r-FbvPzzYUEhpA40YHymsh+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Matan Barak <matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Saeed Mahameed <saeedm-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Eli Cohen <eli-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>, Majd Dibbiny <majd-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	Linux Netdev List <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Saeed Mahameed <saeedm-LDSdmyG8hGV8YrgS2mwiifqBs+8SCbDb@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CALzJLG_CkvbrCehMjMht5KfMK6r-FbvPzzYUEhpA40YHymsh+Q-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wednesday, June 15, 2016 7:04:54 PM CEST Saeed Mahameed wrote:
> 
> Hi Arnd,
> 
> We already took care of those issues, they only apply to Leon's tree
> https://git.kernel.org/cgit/linux/kernel/git/leon/linux-rdma.git/,
> this tree is meant to maintain MLX5 Shared code between netdev and
> linux-rdma trees prior to submission to both trees.
> 
> This patch is a non-shared code and it only exists in
> https://git.kernel.org/cgit/linux/kernel/git/leon/linux-rdma.git/log/?h=topic/net-next-mlx5.
> It is yet to be submitted to Dave's net/net-next tree. later on, this
> patch and all the others will go through the normal submission
> process.

Ok, I see. It would be nice if the process had a way to avoid build regressions
in linux-next, in particular if you already have a fix by the time a patch
that introduces a problem gets added.

Can you check if the fix for the second problem correctly removes the
unnecessary 64-bit division (as opposed to adding a call to div_s64()
or do_div()), and if it removes all traces of 'struct timespec' again?

	Arnd
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
