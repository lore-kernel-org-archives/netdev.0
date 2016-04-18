From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net/mlx4_en: allocate non 0-order pages for RX ring
 with __GFP_NOMEMALLOC
Date: Mon, 18 Apr 2016 05:12:07 -0700
Message-ID: <1460981527.10638.102.camel@edumazet-glaptop3.roam.corp.google.com>
References: <146097923460.15114.8965134124148581055.stgit@buzz>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Yishai Hadas <yishaih@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	linux-kernel@vger.kernel.org
To: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146097923460.15114.8965134124148581055.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2016-04-18 at 14:33 +0300, Konstantin Khlebnikov wrote:
> High order pages are optional here since commit 51151a16a60f ("mlx4: allow
> order-0 memory allocations in RX path"), so here is no reason for depleting
> reserves. Generic __netdev_alloc_frag() implements the same logic.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_rx.c |    2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)

Acked-by: Eric Dumazet <edumazet@google.com>

Thanks !
