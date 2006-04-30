From: Dan Williams <dcbw@redhat.com>
Subject: Re: [AX25, ROSE] Remove useless SET_MODULE_OWNER calls.
Date: Sun, 30 Apr 2006 08:03:26 -0400
Message-ID: <1146398606.2252.1.camel@localhost.localdomain>
References: <20060429142943.GA4402@linux-mips.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-hams@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:8926 "EHLO mx1.redhat.com")
	by vger.kernel.org with ESMTP id S1750795AbWD3MFO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Apr 2006 08:05:14 -0400
To: Ralf Baechle DL5RB <ralf@linux-mips.org>
In-Reply-To: <20060429142943.GA4402@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-04-29 at 15:29 +0100, Ralf Baechle DL5RB wrote:
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>
> 
> --
> 
>  net/netrom/nr_dev.c |    1 -
>  net/rose/rose_dev.c |    1 -
>  2 files changed, 2 deletions(-)
> 
> Index: linux-net.git/net/netrom/nr_dev.c
> ===================================================================
> --- linux-net.git.orig/net/netrom/nr_dev.c	2006-04-29 01:43:47.000000000 +0100
> +++ linux-net.git/net/netrom/nr_dev.c	2006-04-29 11:38:00.000000000 +0100
> @@ -185,7 +185,6 @@ static struct net_device_stats *nr_get_s
>  
>  void nr_setup(struct net_device *dev)
>  {
> -	SET_MODULE_OWNER(dev);
>  	dev->mtu		= NR_MAX_PACKET_SIZE;
>  	dev->hard_start_xmit	= nr_xmit;
>  	dev->open		= nr_open;

Are these done by anything else now?  Did something change to make
SET_MODULE_OWNER useless in individual drivers?  I'm asking because I
was fairly sure that SET_MODULE_OWNER set up some sysfs links and such
that HAL depends on to figure out information about the driver and
hardware device, much like SET_NETDEV_DEV.

Dan


