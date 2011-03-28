From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: notify applications if address of bridge
 device changes
Date: Sun, 27 Mar 2011 18:34:13 -0700 (PDT)
Message-ID: <20110327.183413.229737801.davem@davemloft.net>
References: <20110324162401.2f322e3e@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, bridge@lists.linux-foundation.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753215Ab1C1Bev (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Mar 2011 21:34:51 -0400
In-Reply-To: <20110324162401.2f322e3e@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Thu, 24 Mar 2011 16:24:01 -0700

> The mac address of the bridge device may be changed when a new interface
> is added to the bridge. If this happens, then the bridge needs to call
> the network notifiers to tickle any other systems that care. Since bridge
> can be a module, this also means exporting the notifier function.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Applied, thanks Stephen.
