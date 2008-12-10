From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc9420: SMSC LAN9420 10/100 PCI ethernet adapter
Date: Tue, 09 Dec 2008 23:02:20 -0800 (PST)
Message-ID: <20081209.230220.94138000.davem@davemloft.net>
References: <1228834663-20907-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vlad.lyalikov@smsc.com,
	ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53381
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751820AbYLJHCT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 02:02:19 -0500
In-Reply-To: <1228834663-20907-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue,  9 Dec 2008 14:57:43 +0000

> +uint debug_mode = (DBG_MCAST | DBG_WARNING | DBG_INIT | DBG_CLOSE | DBG_LINK |
> +	DBG_PWR);
> +module_param(debug_mode, uint, 0);
> +MODULE_PARM_DESC(debug_mode, "enables debugging messages");

We have a standard way to do this, and standard bitmask values,
and an ethtool call to set this.  Please use it.

Look at how niu_debug is used in drivers/net/niu.c, functions
like netif_msg_init(), and assosciated interfaces.

There really is no need for this home-grown stuff :-)

Otherwise this driver looks pretty good.
