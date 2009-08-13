From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] myri10ge: improve parity error detection and
 recovery
Date: Wed, 12 Aug 2009 21:18:47 -0700 (PDT)
Message-ID: <20090812.211847.203325604.davem@davemloft.net>
References: <4A7C9226.80401@myri.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brice@myri.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43271
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750729AbZHMESh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Aug 2009 00:18:37 -0400
In-Reply-To: <4A7C9226.80401@myri.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brice Goglin <brice@myri.com>
Date: Fri, 07 Aug 2009 22:44:22 +0200

> Improve myri10ge parity error detection and recovery:
> 1) Don't restore PCI config space to a rebooted NIC until AFTER the
>    host is quiescent.
> 2) Let myri10ge_close() know the NIC is dead, so it won't waste time
>    waiting for a dead nic to respond to MXGEFW_CMD_ETHERNET_DOWN
> 3) When the NIC is quiet (link down, or otherwise idle link) use
>    a pci config space read to detect a rebooted NIC.  Otherwise
>    we might never notice that a NIC rebooted
> 
> Signed-off-by: Andrew Gallatin <gallatin@myri.com>
> Signed-off-by: Brice Goglin <brice@myri.com>

Applied to net-next-2.6
