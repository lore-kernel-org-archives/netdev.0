From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] au1000_eth: get ethernet address from platform_data
Date: Thu, 22 Jul 2010 14:12:01 -0700 (PDT)
Message-ID: <20100722.141201.16642235.davem@davemloft.net>
References: <1279715450-28762-1-git-send-email-manuel.lauss@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, netdev@vger.kernel.org
To: manuel.lauss@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59045
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752107Ab0GVVLo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jul 2010 17:11:44 -0400
In-Reply-To: <1279715450-28762-1-git-send-email-manuel.lauss@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Manuel Lauss <manuel.lauss@googlemail.com>
Date: Wed, 21 Jul 2010 14:30:50 +0200

> au1000_eth uses firmware calls to get a valid MAC address, and changes
> it depending on platform device id.  This patch moves this logic out
> of the driver into the platform device registration part, where boards
> with supported chips can use whatever firmware interface they need;
> the default implementation maintains compatibility with existing,
> YAMON-based firmware.
> 
> Tested-by: Wolfgang Grandegger <wg@denx.de>
> Acked-by: Florian Fainelli <florian@openwrt.org>
> Signed-off-by: Manuel Lauss <manuel.lauss@googlemail.com>
> ---
> This patch depends on another patch to the MIPS tree to
> apply cleanly, so I'd prefer if it went in through it as well.

Ok, feel free:

Acked-by: David S. Miller <davem@davemloft.net>
