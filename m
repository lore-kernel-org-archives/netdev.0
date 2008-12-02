From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mac8390: update to net_device_ops
Date: Tue, 02 Dec 2008 15:00:00 -0800 (PST)
Message-ID: <20081202.150000.134282150.davem@davemloft.net>
References: <20081202081437.7c884ede@extreme>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jgarzik@pobox.com, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57837
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752635AbYLBXAA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 18:00:00 -0500
In-Reply-To: <20081202081437.7c884ede@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 2 Dec 2008 08:14:37 -0800

> Another related 8390 driver. Since this is for nubus, not sure if anyone
> still has the hardware?
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Yeah I wonder how well this one gets build tested.  As you
noticed it is referencing symbols like ____alloc_ei_netdev()
which are static in lib8390.c and not defined anywhere else
I can see.

I'll apply this to net-next-2.6, and if someone is suitably
motivated I'll accept a tested build fix for net-2.6

I won't hold my breath for that, however :-)
