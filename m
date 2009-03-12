From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Wed, 11 Mar 2009 17:44:46 -0700 (PDT)
Message-ID: <20090311.174446.150354252.davem@davemloft.net>
References: <20090311090938.E7BF7832E8B8@gemini.denx.de>
	<20090311.062336.238430706.davem@davemloft.net>
	<20090311191530.GA18211@kos.to>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org
To: riku.voipio@iki.fi
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42888
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752497AbZCLApA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Mar 2009 20:45:00 -0400
In-Reply-To: <20090311191530.GA18211@kos.to>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Riku Voipio <riku.voipio@iki.fi>
Date: Wed, 11 Mar 2009 21:15:30 +0200

> In such machines, typically the mac address is stored in bootloader's
> configuration area in NOR/NAND flash.

That's a perfectly fine solution as well.

Anything that specifies a unique MAC address somewhere on
the board is OK.

It's this "generate a random MAC address every bootup" that
I am totally against.  A situation where there is no permanent
MAC address stored anywhere.
