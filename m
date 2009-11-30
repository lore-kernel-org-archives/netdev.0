From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc9420: prevent BUG() if ethtool is called with
 interface down
Date: Sun, 29 Nov 2009 23:15:13 -0800 (PST)
Message-ID: <20091129.231513.230862834.davem@davemloft.net>
References: <1259166116-5036-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54409
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750869AbZK3HPH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Nov 2009 02:15:07 -0500
In-Reply-To: <1259166116-5036-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Wed, 25 Nov 2009 16:21:56 +0000

> This patch fixes a null pointer dereference BUG() if ethtool is used on
> an smsc9420 interface while it is down, because the phy_dev is only
> allocated while the interface is up.
> 
> Please also consider for -stable.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied and queued up for -stable, thanks.
