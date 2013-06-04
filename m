From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH] net: emaclite: include linux/of_irq.h
Date: Tue, 04 Jun 2013 10:44:36 +0200
Message-ID: <2240834.ApHHSrFxQG@wuerfel>
References: <2244203.EL457oABTU@wuerfel> <51ADA36D.7070607@monstr.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Michal Simek <michal.simek@xilinx.com>
To: monstr@monstr.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:52767 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802Ab3FDIoS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 04:44:18 -0400
In-Reply-To: <51ADA36D.7070607@monstr.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 04 June 2013 10:21:01 Michal Simek wrote:
> On 06/03/2013 11:39 PM, Arnd Bergmann wrote:
> > The emaclite driver now calls of_irq_to_resource, which is
> > declared in linux/of_irq.h. Without this patch, I get a build
> > error on ARM.
> 
> What about to just change it to use platform_get_resource()?
> I will test it.

Yes, that would work too. It seems the driver predates the automatic
generation of resources for IRQs and MMIO registers.

If you change the IRQ resource to platform_get_resource, you should
change the other one as well.

	Arnd
