From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] Tigon3 driver update
Date: Sun, 24 Aug 2003 02:05:00 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030824060500.GA28682@gtf.org>
References: <20030823214939.0c012f3d.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-net@vger.kernel.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20030823214939.0c012f3d.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Aug 23, 2003 at 09:49:39PM -0700, David S. Miller wrote:
> 
> Included is a Tigon3 driver test patch against current
> 2.6.0-testX kernels.
> 
> Features:
> 
> 1) Full 5705/5782/5788/5901 support.
> 2) More reliable PHY resetting on 5703/5704/5705.
> 3) Updated TSO support, it is not enabled by default
>    but one can turn it on using a current version of ethtool.
> 
> Feedback welcome.

Looks good, thanks.  One minor:

The tg3_[gs]et_tso code should be generic, like the tiny helpers at the
top of net/core/ethtool.c.  (well, tg3_get_tso is generic, and
tg3_set_tso could call the generic helper)

	Jeff
