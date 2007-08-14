From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: sysfs locking fix.
Date: Tue, 14 Aug 2007 13:21:45 -0700 (PDT)
Message-ID: <20070814.132145.36923740.davem@davemloft.net>
References: <20070814141105.0a4b8dde@oldman.hamilton.local>
	<20070814131822.GA13676@xi.wantstofly.org>
	<20070814145052.2d135d2f@oldman.hamilton.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: buytenh@wantstofly.org, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bridge@linux-foundation.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58216
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756393AbXHNUVr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 16:21:47 -0400
In-Reply-To: <20070814145052.2d135d2f@oldman.hamilton.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Tue, 14 Aug 2007 14:50:52 +0100

> Forget earlier patch, it is wrong...
> 
> The stp change code generates "sleeping function called from invalid context"
> because rtnl_lock() called with BH disabled. This fixes it by not acquiring then
> dropping the bridge lock.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Applied, thanks Stephen.
