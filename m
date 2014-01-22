From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net-next PATCH 1/1] drivers: net: cpsw: enable promiscuous mode
 support
Date: Wed, 22 Jan 2014 22:53:24 +0530
Message-ID: <52DFFE8C.3020509@ti.com>
References: <1390219718-31749-1-git-send-email-mugunthanvnm@ti.com> <20140121.181137.840971123475894969.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-omap@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:57896 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752510AbaAVRX2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 12:23:28 -0500
In-Reply-To: <20140121.181137.840971123475894969.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 22 January 2014 07:41 AM, David Miller wrote:
> From: Mugunthan V N <mugunthanvnm@ti.com>
> Date: Mon, 20 Jan 2014 17:38:38 +0530
>
>> +		if (!enable && ((priv->slaves[0].ndev->flags & IFF_PROMISC) ||
>> +				(priv->slaves[1].ndev->flags & IFF_PROMISC))) {
> This assumption that there are exactly 2 slaves is not valid.
>
> Use the appropriate for_each_slave() et al. abstractions to access
> the slaves.
Will fix this in next version.

Regards
Mugunthan V N
