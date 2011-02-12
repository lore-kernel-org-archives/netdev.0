From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-26 1/5] cxgb4vf: Virtual Interfaces are always up
 ...
Date: Fri, 11 Feb 2011 21:19:39 -0800 (PST)
Message-ID: <20110211.211939.70197667.davem@davemloft.net>
References: <1297472423-15672-1-git-send-email-leedom@chelsio.com>
	<1297472423-15672-2-git-send-email-leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45166
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751129Ab1BLFTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Feb 2011 00:19:04 -0500
In-Reply-To: <1297472423-15672-2-git-send-email-leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Fri, 11 Feb 2011 17:00:19 -0800

> Implement new default mode of always reporting the Virtual Interface link as
> being "up".  This allows different Virtual Interfaces on the same port to
> continue to communicate with each other even when the physical port link is
> down.  This new behavior is controlled via the module parameter
> force_link_up (default 1).  The old behavior can be achieved by setting
> force_link_up=0.
> 
> Signed-off-by: Casey Leedom <leedom@chelsio.com>

No driver specific module parameters!  Add something generic and common
so other drivers can use it too.

Otherwise every user has to learn a different way to control this
attribute, depending upon the device type, which is rediculious.

How many times do we have to tell driver authors this?
