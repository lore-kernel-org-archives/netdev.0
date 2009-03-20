From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/3] smsc911x: allow setting of mac address
Date: Thu, 19 Mar 2009 23:59:52 -0700 (PDT)
Message-ID: <20090319.235952.85431939.davem@davemloft.net>
References: <1237458286-23421-1-git-send-email-steve.glendinning@smsc.com>
	<1237458286-23421-2-git-send-email-steve.glendinning@smsc.com>
	<1237458286-23421-3-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45340
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752624AbZCTHAF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Mar 2009 03:00:05 -0400
In-Reply-To: <1237458286-23421-3-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Thu, 19 Mar 2009 10:24:46 +0000

> This patch replaces the generic eth_mac_addr function with one that
> also updates the hardware mac address registers.  It also renames the
> existing smsc911x_set_mac_address function to
> smsc911x_hw_set_mac_address for clarity.
> 
> Newer LAN911x and all LAN921x devices also support changing the mac
> address while the device is running, which is useful for some bonding
> modes.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied.
