From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3] tilegx network driver: initial support
Date: Thu, 03 May 2012 01:41:56 -0400 (EDT)
Message-ID: <20120503.014156.149171097979026872.davem@davemloft.net>
References: <201204291859.q3TIxIWB007275@farm-0027.internal.tilera.com>
	<201204301435.08810.arnd@arndb.de>
	<201205011759.q41HxR21020043@farm-0012.internal.tilera.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cmetcalf@tilera.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201205011759.q41HxR21020043@farm-0012.internal.tilera.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Chris Metcalf <cmetcalf@tilera.com>
Date: Mon, 17 Sep 2001 00:00:00 -0400

> +/* #define USE_SIM_PRINTF */
> +
> +#ifdef USE_SIM_PRINTF
> +
> +static __attribute__((unused, format (printf, 1, 2))) void
> +sim_printf(const char *format, ...)
 ...
> +/* HACK: Allow use of "sim_printf()" instead of "printk()". */
> +#define printk sim_printf
> +
> +#endif

This doesn't belong in a driver.

You want a debugging console driver that uses that special SIM output
facility instead.

Therefore, please remove this sim_printf stuff completely.
