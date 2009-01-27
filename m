From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: leave RX_STOP interrupt permanently enabled
Date: Mon, 26 Jan 2009 21:33:27 -0800 (PST)
Message-ID: <20090126.213327.203358341.davem@davemloft.net>
References: <1232985472-16995-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57669
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751727AbZA0Fda (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Jan 2009 00:33:30 -0500
In-Reply-To: <1232985472-16995-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Mon, 26 Jan 2009 15:57:52 +0000

> smsc911x_set_multicast_list currently performs the only non-atomic
> read-modify-write of INT_EN.  This patch permanently enables the
> RXSTOP_INT interrupt, and changes the ISR to only conditionally run the
> multicast filter workaround code.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied to net-next-2.6, thanks Steve.
