From: Ido Schimmel <idosch@idosch.org>
Subject: Re: [PATCH] mlxsw: spectrum_router: Fix use after free
Date: Sun, 14 Aug 2016 18:49:53 +0300
Message-ID: <20160814154953.GA31698@splinter>
References: <1471181909-22187-1-git-send-email-vincent.stehle@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Jiri Pirko <jiri@mellanox.com>
To: Vincent =?iso-8859-1?Q?Stehl=E9?= <vincent.stehle@laposte.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1471181909-22187-1-git-send-email-vincent.stehle@laposte.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, Aug 14, 2016 at 03:38:29PM +0200, Vincent Stehlé wrote:
> In mlxsw_sp_router_fib4_add_info_destroy(), the fib_entry pointer is used
> after it has been freed by mlxsw_sp_fib_entry_destroy(). Use a temporary
> variable to fix this.
> 
> Fixes: 61c503f976b5449e ("mlxsw: spectrum_router: Implement fib4 add/del switchdev obj ops")
> Signed-off-by: Vincent Stehlé <vincent.stehle@laposte.net>
> Cc: Jiri Pirko <jiri@mellanox.com>

Acked-by: Ido Schimmel <idosch@mellanox.com>

Thank you.
