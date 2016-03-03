From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] ethtool.h: define INT_MAX for userland
Date: Thu, 03 Mar 2016 16:43:57 -0500 (EST)
Message-ID: <20160303.164357.745442640403928780.davem@davemloft.net>
References: <1456846141.3098.155.camel@decadent.org.uk>
	<1456850464-23003-1-git-send-email-nicolas.dichtel@6wind.com>
	<1456850464-23003-2-git-send-email-nicolas.dichtel@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ben@decadent.org.uk,
	nikolay@cumulusnetworks.com
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47948 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757806AbcCCVn7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 16:43:59 -0500
In-Reply-To: <1456850464-23003-2-git-send-email-nicolas.dichtel@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Tue,  1 Mar 2016 17:41:04 +0100

> INT_MAX needs limits.h in userland.
> When ethtool.h is included by a userland app, we got the following error:
> 
> .../usr/include/linux/ethtool.h: In function 'ethtool_validate_speed':
> .../usr/include/linux/ethtool.h:1471:18: error: 'INT_MAX' undeclared (first use in this function)
>   return speed <= INT_MAX || speed == SPEED_UNKNOWN
>                   ^
> 
> Fixes: e02564ee334a ("ethtool: make validate_speed accept all speeds between 0 and INT_MAX")
> CC: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>

Applied.
