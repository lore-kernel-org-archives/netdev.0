From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlxsw: spectrum_router: Fix use after free
Date: Sun, 14 Aug 2016 21:33:15 -0700 (PDT)
Message-ID: <20160814.213315.1476217194881057932.davem@davemloft.net>
References: <1471181909-22187-1-git-send-email-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	jiri@mellanox.com
To: vincent.stehle@laposte.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1471181909-22187-1-git-send-email-vincent.stehle@laposte.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vincent Stehlé <vincent.stehle@laposte.net>
Date: Sun, 14 Aug 2016 15:38:29 +0200

> In mlxsw_sp_router_fib4_add_info_destroy(), the fib_entry pointer is used
> after it has been freed by mlxsw_sp_fib_entry_destroy(). Use a temporary
> variable to fix this.
> 
> Fixes: 61c503f976b5449e ("mlxsw: spectrum_router: Implement fib4 add/del switchdev obj ops")
> Signed-off-by: Vincent Stehlé <vincent.stehle@laposte.net>
> Cc: Jiri Pirko <jiri@mellanox.com>

Applied.
