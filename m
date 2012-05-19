From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] drivers/net: delete old 8bit ISA 3c501 driver.
Date: Sat, 19 May 2012 18:33:27 -0400 (EDT)
Message-ID: <20120519.183327.201650385299478436.davem@davemloft.net>
References: <201205182016.51489.linux@rainbow-software.org>
	<20120518220305.GC15256@windriver.com>
	<20120519133038.282d0a7d@bob.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.gortmaker@windriver.com, linux@rainbow-software.org,
	netdev@vger.kernel.org
To: alan@linux.intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:53069 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757826Ab2ESWfy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 May 2012 18:35:54 -0400
In-Reply-To: <20120519133038.282d0a7d@bob.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Cox <alan@linux.intel.com>
Date: Sat, 19 May 2012 13:30:38 +0100

> However I don't think this is the right way to tackle the ethernet
> history situation. As with MCA we should pull *all* the real historical
> interest only bits in one go so it's immediately obvious where the
> break point is for all devices.

I don't think ISA is ever going to be something we can completely
eradicate.

Bits of ISA'ness show up everywhere, from random PC southbridges
to specialized busses shipped on 64-bit sparcs for 8-bit devices
like floppies and serial ports.

Therefore, unlike MCA, ISA is more of a kind of entity we'll have to
eradicate piecemeal I think.
