From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH V2] can: add TI CAN (HECC) driver
Date: Wed, 07 Oct 2009 03:49:17 -0700 (PDT)
Message-ID: <20091007.034917.68739080.davem@davemloft.net>
References: <1254892544-28194-1-git-send-email-anantgole@ti.com>
	<4ACC400C.2020708@grandegger.com>
	<20091007.034425.54165326.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: anantgole@ti.com, netdev@vger.kernel.org,
	socketcan-core@lists.berlios.de,
	linux-arm-kernel@lists.arm.linux.org.uk
To: wg@grandegger.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60395
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758881AbZJGKtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2009 06:49:22 -0400
In-Reply-To: <20091007.034425.54165326.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Wed, 07 Oct 2009 03:44:25 -0700 (PDT)

> From: Wolfgang Grandegger <wg@grandegger.com>
> Date: Wed, 07 Oct 2009 09:15:24 +0200
> 
>> Anant Gole wrote:
>>> TI HECC (High End CAN Controller) module is found on many TI devices. It
>>> has 32 hardware mailboxes with full implementation of CAN protocol 2.0B
>>> with bus speeds up to 1Mbps. Specifications of the module are available
>>> on TI web <http://www.ti.com>
>>> 
>>> Signed-off-by: Anant Gole <anantgole@ti.com>
>> 
>> Signed-off-by: Wolfgang Grandegger <wg@grandegger.com>
>> 
>> Thanks for your contribution.
> 
> Applied, thanks everyone.

Actually I have to revert this.

You have to add restrictions to the Kconfig entry for this
driver so that it only builds where the necessary interfaces
exist.

Otherwise it will fail to link on non-ARM platforms because
they lack the clk_*() functions this driver uses.
