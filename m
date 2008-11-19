From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: add tx checksum offload support
Date: Wed, 19 Nov 2008 14:28:55 -0800 (PST)
Message-ID: <20081119.142855.124711576.davem@davemloft.net>
References: <1226919000-13597-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55422
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750695AbYKSW2z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 17:28:55 -0500
In-Reply-To: <1226919000-13597-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Mon, 17 Nov 2008 10:50:00 +0000

> @@ -757,6 +787,7 @@ static int smsc95xx_phy_initialize(struct usbnet *dev)
>  static int smsc95xx_reset(struct usbnet *dev)
>  {
>  	struct smsc95xx_priv *pdata = (struct smsc95xx_priv *)(dev->data[0]);
> +	struct net_device *netdev = dev->net;
>  	u32 read_buf, write_buf, burst_cap;
>  	int ret = 0, timeout;
>  	DECLARE_MAC_BUF(mac);

This smsc95xx_reset function doesn't even exist in the current driver.
