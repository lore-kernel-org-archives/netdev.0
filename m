From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: Don't put partly initialized fdb into hash
Date: Fri, 04 Feb 2011 13:02:47 -0800 (PST)
Message-ID: <20110204.130247.71096930.davem@davemloft.net>
References: <4D4C2210.8010705@parallels.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	netdev@vger.kernel.org
To: xemul@parallels.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57052
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752235Ab1BDVCM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Feb 2011 16:02:12 -0500
In-Reply-To: <4D4C2210.8010705@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Emelyanov <xemul@parallels.com>
Date: Fri, 04 Feb 2011 18:58:08 +0300

> The fdb_create() puts a new fdb into hash with only addr set. This is
> not good, since there are callers, that search the hash w/o the lock
> and access all the other its fields.
> 
> Applies to current netdev tree.
> 
> Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

Whoa, good catch.  Applied, thanks!
