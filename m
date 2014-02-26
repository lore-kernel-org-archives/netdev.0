From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net, net/mlx4: Add sysfs file for port
 number
Date: Wed, 26 Feb 2014 15:41:24 -0500 (EST)
Message-ID: <20140226.154124.587895988315994922.davem@davemloft.net>
References: <1393345072-31584-1-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ogerlitz@mellanox.com, yevgenyp@mellanox.com,
	netdev@vger.kernel.org, Jordan_Hargrave@Dell.com,
	Narendra_K@Dell.com
To: amirv@mellanox.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40795 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750814AbaBZUl1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 15:41:27 -0500
In-Reply-To: <1393345072-31584-1-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amirv@mellanox.com>
Date: Tue, 25 Feb 2014 18:17:49 +0200

> Modern distro's are using biosdevname to rename interface to a name based on
> slot/port number.
> biosdevname can't get the port number of devices that have multiple ports that
> share the same PCI function.
> This patch adds a sysfs file under: /sys/devices/.../net/<interface>/dev_port,
> that contains the port number (0 based) - to be used by biosdevname.
> Also, dev_id was wrongly used in mlx4_en driver - added a patch that fix it.
> 
> This patch was tested and applied over commit 51adfcc "net: bcmgenet: remove
> unused bh_lock member"

Series applied, thanks.
