From: Andi Kleen <ak@colin2.muc.de>
Subject: Re: [PATCH] Fix 64bit warnings in rtl8139too
Date: 14 Oct 2003 21:49:14 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20031014194914.GA58843@colin2.muc.de>
References: <20031007175638.GA1754@averell> <3F8C3CB0.9090502@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <ak@muc.de>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Tue, 14 Oct 2003 21:49:14 +0200
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <3F8C3CB0.9090502@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 14, 2003 at 02:13:04PM -0400, Jeff Garzik wrote:
> Andi Kleen wrote:
> >Fix a harmless 64bit pointer/integer mismatch warning in 8139too.
> >
> >diff -u linux-2.5-cleanup/drivers/net/8139too.c-o 
> >linux-2.5-cleanup/drivers/net/8139too.c
> >--- linux-2.5-cleanup/drivers/net/8139too.c-o	2003-09-08 
> >00:02:03.000000000 +0200
> >+++ linux-2.5-cleanup/drivers/net/8139too.c	2003-12-02 
> >17:13:24.634752560 +0100
> >@@ -746,7 +746,8 @@
> > 	u8 tmp8;
> > 	int rc;
> > 	unsigned int i;
> >-	u32 pio_start, pio_end, pio_flags, pio_len;
> >+	unsigned long pio_start;
> >+	u32 pio_end, pio_flags, pio_len;
> > 	unsigned long mmio_start, mmio_end, mmio_flags, mmio_len;
> > 	u32 version;
> 
> 
> Why not just make this look like mmio_*?

No problems, feel free to do that.

I just did the minimal change to fix the warning.

-Andi
