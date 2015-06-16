From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bridge: del external_learned fdbs from device
 on flush or ageout
Date: Mon, 15 Jun 2015 17:09:24 -0700 (PDT)
Message-ID: <20150615.170924.2212463704435329039.davem@davemloft.net>
References: <1434306791-43364-1-git-send-email-sfeldma@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@resnulli.us,
	roopa@cumulusnetworks.com, john.r.fastabend@intel.com,
	andrew@lunn.ch, f.fainelli@gmail.com, linux@roeck-us.net,
	stephen@networkplumber.org
To: sfeldma@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:42746 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750717AbbFPAJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 20:09:27 -0400
In-Reply-To: <1434306791-43364-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: sfeldma@gmail.com
Date: Sun, 14 Jun 2015 11:33:11 -0700

> From: Scott Feldman <sfeldma@gmail.com>
> 
> We need to delete from offload the device externally learnded fdbs when any
> one of these events happen:
> 
> 1) Bridge ages out fdb.  (When bridge is doing ageing vs. device doing
> ageing.  If device is doing ageing, it would send SWITCHDEV_FDB_DEL
> directly).
> 
> 2) STP state change flushes fdbs on port.
> 
> 3) User uses sysfs interface to flush fdbs from bridge or bridge port:
> 
> 	echo 1 >/sys/class/net/BR_DEV/bridge/flush
> 	echo 1 >/sys/class/net/BR_PORT/brport/flush
> 
> 4) Offload driver send event SWITCHDEV_FDB_DEL to delete fdb entry.
> 
> For rocker, we can now get called to delete fdb entry in wait and nowait
> contexts, so set NOWAIT flag when deleting fdb entry.
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>

Applied, thanks Scott.
