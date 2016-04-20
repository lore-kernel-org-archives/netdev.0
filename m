From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/mlx4_en: do batched put_page using atomic_sub
Date: Tue, 19 Apr 2016 20:07:09 -0400 (EDT)
Message-ID: <20160419.200709.1456260686653504927.davem@davemloft.net>
References: <146097924572.15144.10837875571142670008.stgit@buzz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yishaih@mellanox.com, eugenia@mellanox.com,
	linux-kernel@vger.kernel.org
To: khlebnikov@yandex-team.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <146097924572.15144.10837875571142670008.stgit@buzz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>
Date: Mon, 18 Apr 2016 14:34:05 +0300

> This patch fixes couple error paths after allocation failures.
> Atomic set of page reference counter is safe only if it is zero,
> otherwise set can race with any speculative get_page_unless_zero.
> 
> Signed-off-by: Konstantin Khlebnikov <khlebnikov@yandex-team.ru>

Applied.
