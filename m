From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipconfig: handle case of delayed DHCP server
Date: Fri, 08 May 2009 14:39:47 -0700 (PDT)
Message-ID: <20090508.143947.207466029.davem@davemloft.net>
References: <4A049C6B.9070000@nortel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: cfriesen@nortel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39737
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751093AbZEHVjv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 May 2009 17:39:51 -0400
In-Reply-To: <4A049C6B.9070000@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Chris Friesen" <cfriesen@nortel.com>
Date: Fri, 08 May 2009 14:56:11 -0600

> 
> +	/* Is it a reply for the device we are configuring? */
> +	if (b->xid != ic_dev_xid) {
> +		if (net_ratelimit())
> + printk(KERN_ERR "DHCP/BOOTP: Ignoring delayed packet \n");
> +		goto drop_unlock;

Please don't use such odd indentation for this printk
statement.
