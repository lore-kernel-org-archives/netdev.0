From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH] (3/12) skge: remove unneeded include's
Date: Thu, 3 Mar 2005 21:51:16 +0000
Message-ID: <20050303215116.GA16132@infradead.org>
References: <20050303113413.1bcd7476@dxpl.pdx.osdl.net> <42278470.2070807@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@oss.sgi.com
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <42278470.2070807@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Thu, Mar 03, 2005 at 04:41:04PM -0500, Jeff Garzik wrote:
> Stephen Hemminger wrote:
> >Get rid of unnecessary include's
> >
> >Signed-off-by: Stephen Hemminger <shemminger@osdl.org>
> >
> >--- skge-2.6.11/drivers/net/skge.c.orig	2005-03-02 
> >17:15:44.000000000 -0800
> >+++ skge-2.6.11/drivers/net/skge.c	2005-03-02 17:17:25.000000000 -0800
> >@@ -30,13 +30,10 @@
> > #include <linux/moduleparam.h>
> > #include <linux/netdevice.h>
> > #include <linux/etherdevice.h>
> >-#include <linux/dma-mapping.h>
> 
> Why is this one is unnecessary?

Becasue the driver is using the pci_ variants of the dma mapping routines,
which are in pci.h
