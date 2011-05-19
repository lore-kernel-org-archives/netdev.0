From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] networking: NET_CLS_ROUTE4 depends on INET
Date: Thu, 19 May 2011 19:23:44 -0400 (EDT)
Message-ID: <20110519.192344.1672617698095090949.davem@davemloft.net>
References: <20110519162218.b0344392.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hadi@cyberus.ca
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:49656 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933506Ab1ESXXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2011 19:23:51 -0400
In-Reply-To: <20110519162218.b0344392.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 19 May 2011 16:22:18 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> IP_ROUTE_CLASSID depends on INET and NET_CLS_ROUTE4 selects
> IP_ROUTE_CLASSID, but when INET is not enabled, this kconfig warning
> is produced, so fix it by making NET_CLS_ROUTE4 depend on INET.
> 
> warning: (NET_CLS_ROUTE4) selects IP_ROUTE_CLASSID which has unmet direct dependencies (NET && INET)
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Applied, thanks Randy.
