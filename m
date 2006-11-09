From: Olaf Hering <olaf@aepfle.de>
Subject: Re: [PATCH] mark non-compiling ISA network drivers i386 only
Date: Fri, 10 Nov 2006 00:09:52 +0100 (MET)
Message-ID: <20061109230953.GF28237@aepfle.de>
References: <20061109184021.GA25691@aepfle.de> <20061109113542.7bbb232b@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p07-ob.rzone.de ([81.169.146.188]:26966 "EHLO
	mo-p07-ob.rzone.de") by vger.kernel.org with ESMTP id S1424242AbWKIXMz
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 9 Nov 2006 18:12:55 -0500
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061109113542.7bbb232b@dxpl.pdx.osdl.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 09, Stephen Hemminger wrote:

> On Thu, 9 Nov 2006 19:40:21 +0100 (MET)
> Olaf Hering <olaf@aepfle.de> wrote:
> 
> > 
> > Provide drivers for the old toys only on i386
> > isa_bus_to_virt is defined only on i386, mips and arm
> > isa_virt_to_bus is used for floppy.ko
> 
> Why not mark all of ISA as i386, mips, arm only?

This patch is mainly for users of these 3 macros:

'(isa_virt_to_bus|isa_page_to_bus|isa_bus_to_virt)'

3c505.c 3c515.c 3c523.c 3c527.c aha1542.c cs89x0.c esp.c ibmmca.c
lance.c mca_53c9x.c ni52.c ni65.c ps2esdi.c ultrastor.c wd7000.c

I did not enable all of them in a ppc32 pmac config.
ppc32 PReP does have ISA slots on the motorola boards, no idea if anyone
really cares about ISA cards today.
