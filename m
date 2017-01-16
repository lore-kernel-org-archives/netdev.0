From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/1] ax25: Fix segfault after sock connection timeout
Date: Mon, 16 Jan 2017 14:40:51 -0500 (EST)
Message-ID: <20170116.144051.1777999685832100508.davem@davemloft.net>
References: <20170114121855.62254455@brox.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jreuter@yaina.de, ralf@linux-mips.org, linux-hams@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        stable@vger.kernel.org, mcdermj@xenotropic.com, f6bvp@free.fr
To: basil@pacabunga.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170114121855.62254455@brox.localnet>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Basil Gunn <basil@pacabunga.com>
Date: Sat, 14 Jan 2017 12:18:55 -0800

> The ax.25 socket connection timed out & the sock struct has been
> previously taken down ie. sock struct is now a NULL pointer. Checking
> the sock_flag causes the segfault.  Check if the socket struct pointer
> is NULL before checking sock_flag. This segfault is seen in
> timed out netrom connections.
> 
> Please submit to -stable.
> 
> Signed-off-by: Basil Gunn <basil@pacabunga.com>

This is consistent with the ax25->sk NULL check later in this function.

Applied and queued up for -stable, thanks.
