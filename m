From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: remove EEPROM loaded check
Date: Sun, 02 Aug 2009 12:56:31 -0700 (PDT)
Message-ID: <20090802.125631.134874410.davem@davemloft.net>
References: <1248784678-31726-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59213
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753477AbZHBT4X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Aug 2009 15:56:23 -0400
In-Reply-To: <1248784678-31726-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Tue, 28 Jul 2009 13:37:58 +0100

> The eeprom read & write commands currently check the E2P_CMD_LOADED_ bit is
> set before allowing any operations.  This prevents any reading or writing
> unless a correctly programmed EEPROM is installed.
> 
> This patch removes the check, so it is possible to program blank EEPROMS
> via ethtool.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied to net-next-2.6
