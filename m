From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 4/4] bridge: update sysfs link names if port device
 names have changed
Date: Sat, 15 May 2010 23:12:29 -0700 (PDT)
Message-ID: <20100515.231229.186295968.davem@davemloft.net>
References: <20100510193107.722574297@vyatta.com>
	<20100510193321.020451781@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	simon@fire.lp0.eu
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60902
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751952Ab0EPGMU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 May 2010 02:12:20 -0400
In-Reply-To: <20100510193321.020451781@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 10 May 2010 12:31:11 -0700

> From: Simon Arlott <simon@fire.lp0.eu>
> 
> Links for each port are created in sysfs using the device
> name, but this could be changed after being added to the
> bridge.
> 
> As well as being unable to remove interfaces after this
> occurs (because userspace tools don't recognise the new
> name, and the kernel won't recognise the old name), adding
> another interface with the old name to the bridge will
> cause an error trying to create the sysfs link.
> 
> This fixes the problem by listening for NETDEV_CHANGENAME
> notifications and renaming the link.
> 
> https://bugzilla.kernel.org/show_bug.cgi?id=12743
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>
> Acked-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
