From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] vlan: allow creating vlan when real device is not up
Date: Thu, 30 Jul 2009 13:17:10 -0700 (PDT)
Message-ID: <20090730.131710.208062164.davem@davemloft.net>
References: <20090730112321.35753739@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36180
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751803AbZG3URD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jul 2009 16:17:03 -0400
In-Reply-To: <20090730112321.35753739@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 30 Jul 2009 11:23:21 -0700

> There is no reason for the arbitrary restriction that device must be
> up to create a vlan. This patch was added to Vyatta kernel to resolve startup
> ordering issues where vlan's are created but real device was disabled.
> 
> Note: the vlan already correctly inherits the operstate from real device; so
> if vlan is created and real device is marked down, the vlan is marked
> down.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Looks fine, added to net-next-2.6

We can revert if Patrick or someone else finds a potential problem
with allowing this.

Thanks.
