From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] atmtcp: add sysfs attr for changing atm carrier signal
 state.
Date: Sun, 03 Oct 2010 13:00:57 -0700 (PDT)
Message-ID: <20101003.130057.226762538.davem@davemloft.net>
References: <1286135485-27355-1-git-send-email-karl@hiramoto.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-atm-general@lists.sourceforge.net,
	chas@cmf.nrl.navy.mil
To: karl@hiramoto.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55462
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754454Ab0JCUAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Oct 2010 16:00:36 -0400
In-Reply-To: <1286135485-27355-1-git-send-email-karl@hiramoto.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Karl Hiramoto <karl@hiramoto.org>
Date: Sun,  3 Oct 2010 21:51:25 +0200

> This will be used for device testing carrier signal changes in other parts of
> the atm stack.
> 
> Carrier lost set by:
> echo -n 0 > /sys/class/atm/atmtcp0/carrier
> 
> Carrier detected:
> echo -n 1 > /sys/class/atm/atmtcp0/carrier
> 
> Signed-off-by: Karl Hiramoto <karl@hiramoto.org>

We already have enough sysfs hacky knobs.

And for something as fundamental as setting the carrier status, it's
not acceptable to add a device-type specific control.

Use something we have already, either via core device state management
(via netlink or ifconfig's ioctls) or ethtool.

Thanks.
