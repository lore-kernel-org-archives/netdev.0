From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] mark non-compiling ISA network drivers i386 only
Date: Thu, 9 Nov 2006 11:35:42 -0800
Message-ID: <20061109113542.7bbb232b@dxpl.pdx.osdl.net>
References: <20061109184021.GA25691@aepfle.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org,
	Ralf Baechle <ralf@linux-mips.org>,
	Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:15016 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030402AbWKIThX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Nov 2006 14:37:23 -0500
To: Olaf Hering <olaf@aepfle.de>
In-Reply-To: <20061109184021.GA25691@aepfle.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 9 Nov 2006 19:40:21 +0100 (MET)
Olaf Hering <olaf@aepfle.de> wrote:

> 
> Provide drivers for the old toys only on i386
> isa_bus_to_virt is defined only on i386, mips and arm
> isa_virt_to_bus is used for floppy.ko

Why not mark all of ISA as i386, mips, arm only?
