From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: af802154: Fix wrong structure declaration
Date: Tue, 08 Oct 2013 15:49:10 -0400 (EDT)
Message-ID: <20131008.154910.1164614425435689551.davem@davemloft.net>
References: <1381095841-15031-1-git-send-email-linux@roeck-us.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: linux@roeck-us.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54294 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab3JHTtM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Oct 2013 15:49:12 -0400
In-Reply-To: <1381095841-15031-1-git-send-email-linux@roeck-us.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guenter Roeck <linux@roeck-us.net>
Date: Sun,  6 Oct 2013 14:44:01 -0700

> net_devce doesn't exist.
> 
> Signed-off-by: Guenter Roeck <linux@roeck-us.net>

This is simply rediculous.

The reason I say this is that every user of this header includes
net/sock.h which in turn includes linux/skbuff.h and linux/netdevice.h
which therefore bring in all the necessary structure definitions.

Really, the most correct change is to make af802154.h explicitly
include those header files.
