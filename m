From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net namespace: build when SYSCTL=n
Date: Fri, 18 Jul 2008 18:01:07 -0700 (PDT)
Message-ID: <20080718.180107.126477208.davem@davemloft.net>
References: <20080718171812.8dfc9767.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41538
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752570AbYGSBBH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Jul 2008 21:01:07 -0400
In-Reply-To: <20080718171812.8dfc9767.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Fri, 18 Jul 2008 17:18:12 -0700

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> When CONFIG_SYSCTL=n, build fails with:
> 
> linux-next-20080718/include/net/net_namespace.h:40: error: field 'sysctls' has incomplete type
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

This 'sysctls' member isn't present in my networking tree, it must be
coming from some other tree and thus the patch needs to be applied
there.
