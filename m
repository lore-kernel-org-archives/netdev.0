From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: fix BUG if module is removed while interface
 is up
Date: Thu, 25 Dec 2008 16:41:36 -0800 (PST)
Message-ID: <20081225.164136.50288180.davem@davemloft.net>
References: <1229695418-27275-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55981
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752108AbYLZAle (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Dec 2008 19:41:34 -0500
In-Reply-To: <1229695418-27275-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Fri, 19 Dec 2008 14:03:38 +0000

> If the module is removed while its interface is up, smsc911x_stop is not
> called until after smsc911x_drv_remove has disposed of phy_dev.  This
> patch changes the stop method to handle this situation.
> 
> This is a different problem to the one reported by dfoley@telus.net.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
