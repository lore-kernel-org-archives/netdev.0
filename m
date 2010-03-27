From: David Miller <davem@davemloft.net>
Subject: Re: Seeing new kernel unaligned access messages in linux-next on
 ia64
Date: Sat, 27 Mar 2010 16:37:30 -0700 (PDT)
Message-ID: <20100327.163730.179928738.davem@davemloft.net>
References: <alpine.LSU.2.01.1003250014400.16715@obet.zrqbmnf.qr>
	<20100324.203249.97351120.davem@davemloft.net>
	<alpine.LSU.2.01.1003271313230.2740@obet.zrqbmnf.qr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: schwab@linux-m68k.org, tony.luck@intel.com, netdev@vger.kernel.org
To: jengelh@medozas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53941
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754049Ab0C0XhH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Mar 2010 19:37:07 -0400
In-Reply-To: <alpine.LSU.2.01.1003271313230.2740@obet.zrqbmnf.qr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Engelhardt <jengelh@medozas.de>
Date: Sat, 27 Mar 2010 13:14:46 +0100 (CET)

> net: fix unaligned access in IFLA_STATS64

Applied to net-next-2.6, thanks Jan.

Hey, don't we need some adjustments to if_nlmsg_size()?  I don't see
it accounting for IFLA_STATS64/"struct rtnl_link_stats64" there.

