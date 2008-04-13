From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tg3: fix MMIO for PPC 44x platforms
Date: Sat, 12 Apr 2008 18:31:20 -0700 (PDT)
Message-ID: <20080412.183120.265079925.davem@davemloft.net>
References: <200804122101.22438.sshtylyov@ru.mvista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: sshtylyov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39635
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753873AbYDMBbT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Apr 2008 21:31:19 -0400
In-Reply-To: <200804122101.22438.sshtylyov@ru.mvista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sergei Shtylyov <sshtylyov@ru.mvista.com>
Date: Sat, 12 Apr 2008 21:01:22 +0400

> The driver stores the PCI resource addresses into 'unsigned long' variable
> before calling ioremap_nocache() on them. This warrants kernel oops when the
> registers are accessed on PPC 44x platforms which (being 32-bit) have PCI
> memory space mapped beyond 4 GB.
> 
> The arch/ppc/ kernel has a fixup in ioremap() that creates an illusion that
> the PCI memory resource is mapped below 4 GB, but arch/powerpc/ code got rid
> of this trick, having instead CONFIG_RESOURCES_64BIT enabled.
> 
> Signed-off-by: Sergei Shtylyov <sshtylyov@ru.mvista.com>

Applied, thanks.

I added a bump of the driver version and release date for
the changeset.
