From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 08/10] ipv6: use RCU to walk list of network devices
Date: Tue, 10 Nov 2009 22:50:01 -0800 (PST)
Message-ID: <20091110.225001.212427257.davem@davemloft.net>
References: <20091110175446.280423729@vyatta.com>
	<20091110175647.683253741@vyatta.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40936
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753357AbZKKGtf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Nov 2009 01:49:35 -0500
In-Reply-To: <20091110175647.683253741@vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Tue, 10 Nov 2009 09:54:54 -0800

> No longer need read_lock(&dev_base_lock), use RCU instead.
> This also needs to be optimized for large number of devices.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

As Eric mentioned, superceded by his patch.
