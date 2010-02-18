From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 14/15] drivers/net/typhoon.c: Use
 (pr|netdev)_<level> macro helpers
Date: Wed, 17 Feb 2010 18:41:00 -0800 (PST)
Message-ID: <20100217.184100.232538560.davem@davemloft.net>
References: <1266458370.5719.43.camel@obelisk.thedillows.org>
	<1266459504.8446.201.camel@Joe-Laptop.home>
	<1266460221.5719.60.camel@obelisk.thedillows.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: joe@perches.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: dave@thedillows.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36493
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755106Ab0BRCkp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 21:40:45 -0500
In-Reply-To: <1266460221.5719.60.camel@obelisk.thedillows.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Dillow <dave@thedillows.org>
Date: Wed, 17 Feb 2010 21:30:21 -0500

> No, because the routines that use tp->name are called both before and
> after the netdev is registered. Prior to that time, it contains the PCI
> slot name -- "00:01.0" etc -- so that the user can determine which card
> is acting up. Once the card is registered, it has "ethX" to use a
> commonly expected name for the card.

In my opinion that's awful.

Pick one or the other format.  For things that happen both
before and after netdev registry we really should provide
one style of device identification and those provided
by dev_*() are probably the best in these situations.
