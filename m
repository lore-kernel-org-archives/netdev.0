From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.24-rc2] net: net_free implicit declaration
Date: Tue, 06 Nov 2007 19:17:04 -0800 (PST)
Message-ID: <20071106.191704.193701495.davem@davemloft.net>
References: <20071106190629.f77560fb.randy.dunlap@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	torvalds@linux-foundation.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40839
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753514AbXKGDRG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Nov 2007 22:17:06 -0500
In-Reply-To: <20071106190629.f77560fb.randy.dunlap@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Tue, 6 Nov 2007 19:06:29 -0800

> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Just move the function so that is it known before it is used.
> 
> net/core/net_namespace.c: In function 'copy_net_ns':
> net/core/net_namespace.c:97: error: implicit declaration of function 'net_free'
> net/core/net_namespace.c: At top level:
> net/core/net_namespace.c:104: warning: conflicting types for 'net_free'
> net/core/net_namespace.c:104: error: static declaration of 'net_free' follows non-static declaration
> net/core/net_namespace.c:97: error: previous implicit declaration of 'net_free' was here
> make[2]: *** [net/core/net_namespace.o] Error 1
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

This is already fixed in the net-2.6 tree.
I'll push it to Linus after I'm done sorting another bug.
