From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] cxgb4: new driver submission
Date: Wed, 17 Feb 2010 17:59:27 -0800 (PST)
Message-ID: <20100217.175927.88022884.davem@davemloft.net>
References: <1266457062-31150-1-git-send-email-dm@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dm@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46644
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932346Ab0BRB7M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Feb 2010 20:59:12 -0500
In-Reply-To: <1266457062-31150-1-git-send-email-dm@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dimitris Michailidis <dm@chelsio.com>
Date: Wed, 17 Feb 2010 17:37:35 -0800

> 
> The following 7 patches add a new driver cxgb4 for Chelsio's new 1G and 10G
> cards.  At this time this is for review and comments, I'll be sending an
> updated patch series once any review comments are incorporated.

There is lots of trailing whitespace added by your changes.
There's also a case of spaces followed by tab characters in
the initial indentation of lines.

What makes those two things so incredibly inexcusable is that the very
tools we use to add changes to the tree _tell_ you about these things.

bundle-895.mbox:6829: trailing whitespace.
	FW_STAT_TX_PORT_FRAMES_IX,	
bundle-895.mbox:6879: trailing whitespace.
	FW_STAT_RX_PORT_PPP7_IX,	
bundle-895.mbox:6985: trailing whitespace.
	FW_STAT_LB_PORT_FRAMES_IX, 	
bundle-895.mbox:6986: trailing whitespace.
	FW_STAT_LB_PORT_BCAST_IX, 
bundle-895.mbox:9918: trailing whitespace.
	int ret; 
bundle-895.mbox:10135: space before tab in indent.
       	if (mac) {
bundle-895.mbox:12533: trailing whitespace.
 *	prevent further unmapping attempts. 
bundle-895.mbox:18605: trailing whitespace.
	
bundle-895.mbox:18981: trailing whitespace.
		dev_info(adap->pdev_dev, 
bundle-895.mbox:19266: trailing whitespace.
		
fatal: 10 lines add whitespace errors.

Such automated clerical issues should be taken care of before you even
submit this for "review".  It's the same as making sure the code
compiles.

Also you should use the netdev_*() message logging helpers added
by Joe Perches instead of your local CMSG_*() hacks.

Finally, this V_*, S_*, F_* naming scheme for register values is
backwards and if anything very non-standard.  Please use normal macro
names for these things so you code is more readable by people who
have to look at all of the other device drivers in the tree not
just your's.
