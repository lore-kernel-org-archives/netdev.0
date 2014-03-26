From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] smsc911x: Do not use netdev_dbg() when device is
 not registered
Date: Wed, 26 Mar 2014 15:46:37 -0400 (EDT)
Message-ID: <20140326.154637.45084878742038706.davem@davemloft.net>
References: <1395676646-14178-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, netdev@vger.kernel.org,
	sergei.shtylyov@cogentembedded.com
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:46286 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753126AbaCZTqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Mar 2014 15:46:39 -0400
In-Reply-To: <1395676646-14178-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 24 Mar 2014 12:57:25 -0300

> With debug enabled we get the following message:
> 
> smsc911x smsc911x (unregistered net_device): couldn't get clock -2
> 
> As the device has not been registered at this point, it is better to use 
> dev_dbg() instead of netdev_dbg().
> 
> CC: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> Suggested-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>

Applied.
