From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 08/12] drivers/net: replace __FUNCTION__ with __func__
Date: Sat, 13 Sep 2008 19:14:22 -0400
Message-ID: <48CC494E.5050303@garzik.org>
References: <200808202352.m7KNq5u9006053@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, harvey.harrison@gmail.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41875 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753010AbYIMXOZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 19:14:25 -0400
In-Reply-To: <200808202352.m7KNq5u9006053@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

akpm@linux-foundation.org wrote:
> From: Harvey Harrison <harvey.harrison@gmail.com>
> 
> __FUNCTION__ is gcc-specific, use __func__
> 
> Signed-off-by: Harvey Harrison <harvey.harrison@gmail.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/3c505.c               |    4 
>  drivers/net/arcnet/arcnet.c       |   18 ++--
>  drivers/net/arcnet/com20020.c     |   16 +--
>  drivers/net/ax88796.c             |   14 +--
>  drivers/net/bfin_mac.c            |    8 -
>  drivers/net/bonding/bonding.h     |    2 
>  drivers/net/cxgb3/cxgb3_offload.c |    8 -
>  drivers/net/e100.c                |    2 
>  drivers/net/enc28j60.c            |   56 ++++++-------
>  drivers/net/ibm_newemac/phy.c     |    2 
>  drivers/net/ixgb/ixgb.h           |    2 
>  drivers/net/ixgbe/ixgbe.h         |    2 
>  drivers/net/meth.c                |    2 
>  drivers/net/mipsnet.c             |    2 
>  drivers/net/netx-eth.c            |    2 
>  drivers/net/netxen/netxen_nic.h   |    2 
>  drivers/net/pci-skeleton.c        |    4 
>  drivers/net/r8169.c               |    2 
>  drivers/net/s2io.c                |   40 ++++-----
>  drivers/net/smc911x.c             |   66 +++++++--------
>  drivers/net/smc91x.c              |   40 ++++-----
>  drivers/net/tehuti.h              |    8 -
>  drivers/net/tsi108_eth.c          |    6 -
>  drivers/net/ucc_geth.c            |  116 ++++++++++++++--------------
>  drivers/net/usb/mcs7830.c         |    2 
>  drivers/net/usb/pegasus.c         |   24 ++---
>  drivers/net/via-velocity.h        |    2 
>  drivers/net/wan/cycx_drv.c        |    6 -
>  drivers/net/wan/cycx_x25.c        |   12 +-
>  drivers/net/wan/dscc4.c           |    2 
>  drivers/net/wan/pc300_tty.c       |    2 
>  31 files changed, 237 insertions(+), 237 deletions(-)

applied 98% of this


