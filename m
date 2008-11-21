From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 7/9] ipip: convert to net_device_ops
Date: Thu, 20 Nov 2008 20:33:29 -0800 (PST)
Message-ID: <20081120.203329.223345788.davem@davemloft.net>
References: <20081120175913.943543638@vyatta.com>
	<20081120175934.092348986@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59508
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752040AbYKUEd3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 23:33:29 -0500
In-Reply-To: <20081120175934.092348986@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 20 Nov 2008 09:59:20 -0800

> Convert to network device ops. Needed to change to directly call
> the init routine since two sides share same ops.  In the process
> found by inspection a device ref count leak if register_netdevice failed.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied.
