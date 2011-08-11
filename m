From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] PCnet: Fix section mismatch
Date: Thu, 11 Aug 2011 07:42:55 -0700 (PDT)
Message-ID: <20110811.074255.1123597785105932021.davem@davemloft.net>
References: <20110810152346.GA6092@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pcnet32@frontier.com, netdev@vger.kernel.org,
	tsbogend@alpha.franken.de, linux-mips@linux-mips.org
To: ralf@linux-mips.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54174 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750825Ab1HKOnS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 10:43:18 -0400
In-Reply-To: <20110810152346.GA6092@linux-mips.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ralf Baechle <ralf@linux-mips.org>
Date: Wed, 10 Aug 2011 16:23:46 +0100

> Building MIPS mtx1_defconfig results in:
> 
>   MODPOST 735 modules
> WARNING: drivers/net/pcnet32.o(.devinit.text+0x11ec): Section mismatch in reference from the function pcnet32_probe_vlbus.constprop.22() to the variable .init.data:pcnet32_portlist
> The function __devinit pcnet32_probe_vlbus.constprop.22() references
> a variable __initdata pcnet32_portlist.
> If pcnet32_portlist is only used by pcnet32_probe_vlbus.constprop.22 then
> annotate pcnet32_portlist with a matching annotation.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied, thanks Ralf.
