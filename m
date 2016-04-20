From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_en: allocate non 0-order pages for RX ring
 with __GFP_NOMEMALLOC
Date: Tue, 19 Apr 2016 20:07:04 -0400 (EDT)
Message-ID: <20160419.200704.829287730580225238.davem@davemloft.net>
References: <146097923460.15114.8965134124148581055.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yishaih@mellanox.com, eugenia@mellanox.com,
	linux-kernel@vger.kernel.org
To: khlebnikov@yandex-team.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146097923460.15114.8965134124148581055.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 18 Apr 2016 14:33:54 +0300

> High order pages are optional here since commit 51151a16a60f ("mlx4: allow
> order-0 memory allocations in RX path"), so here is no reason for depleting
> reserves. Generic __netdev_alloc_frag() implements the same logic.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied.
