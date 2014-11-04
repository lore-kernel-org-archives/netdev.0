From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: phy: spi_ks8995: remove sysfs bin file by
 registered attribute
Date: Tue, 04 Nov 2014 17:19:07 -0500 (EST)
Message-ID: <20141104.171907.669153630072897147.davem@davemloft.net>
References: <1415057109-8506-1-git-send-email-vz@mleia.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, f.fainelli@gmail.com
To: vz@mleia.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59896 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752911AbaKDWTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Nov 2014 17:19:10 -0500
In-Reply-To: <1415057109-8506-1-git-send-email-vz@mleia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vladimir Zapolskiy <vz@mleia.com>
Date: Tue,  4 Nov 2014 01:25:09 +0200

> When a sysfs binary file is asked to be removed, it is found by
> attribute name, so strictly speaking this change is not a fix, but
> just in case when attribute name is changed in the driver or sysfs
> internals are changed, it might be better to remove the previously
> created file using right the same binary attribute.
> 
> Signed-off-by: Vladimir Zapolskiy <vz@mleia.com>

Applied to net-next, thanks.
