From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [patch 02/11] vioc-warning-fix
Date: Fri, 27 Apr 2007 20:27:42 -0400
Message-ID: <463294FE.5060804@garzik.org>
References: <200704260723.l3Q7NF6G023823@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, driver-support@fabric7.com,
	schidambaram@fabric7.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:48313 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757965AbXD1A1p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 27 Apr 2007 20:27:45 -0400
In-Reply-To: <200704260723.l3Q7NF6G023823@shell0.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

akpm@linux-foundation.org wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Fix this, on i386:
> 
> drivers/net/vioc/vioc_transmit.c: In function 'vioc_tx_interrupt':
> drivers/net/vioc/vioc_transmit.c:387: warning: cast from pointer to integer of different size
> 
> I dunno what the driver is trying to do here, but it looks unpleasant.
> 
> Cc: Sriram Chidambaram <schidambaram@fabric7.com>
> Cc: Fabric7 Driver-Support <driver-support@fabric7.com>
> Cc: Jeff Garzik <jeff@garzik.org>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
> ---
> 
>  drivers/net/vioc/vioc_vnic.h |    6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)

applied these three vioc patches


