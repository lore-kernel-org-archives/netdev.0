From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [Bug 9187] ir-functions.c:(.text+0xbce18): undefined
 reference to `input_event'
Date: Thu, 18 Oct 2007 22:02:22 -0700 (PDT)
Message-ID: <20071018.220222.35036834.davem@davemloft.net>
References: <20071019035702.B5C7E108010@picon.linux-foundation.org>
	<4718385E.7050105@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bugme-daemon@bugzilla.kernel.org, netdev@vger.kernel.org,
	jeff@garzik.org
To: randy.dunlap@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40497
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754135AbXJSFCI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Oct 2007 01:02:08 -0400
In-Reply-To: <4718385E.7050105@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Randy Dunlap <randy.dunlap@oracle.com>
Date: Thu, 18 Oct 2007 21:53:50 -0700

> [bugme-daemon@bugzilla.kernel.org wrote:]
> 
> 
> 
> From: Randy Dunlap <randy.dunlap@oracle.com>
> 
> Drivers that use lro functions should depend on INET, otherwise they
> may not link correctly.  Let's not select INET.  Select should be used
> only for library-like code, not to enable subsystems.
> 
> ERROR: "lro_flush_all" [drivers/net/myri10ge/myri10ge.ko] undefined!
> ERROR: "lro_receive_frags" [drivers/net/myri10ge/myri10ge.ko] undefined!
> 
> Signed-off-by: Randy Dunlap <randy.dunlap@oracle.com>

Acked-by: David S. Miller <davem@davemloft.net>

Jeff, please pick this one up too, thanks!
