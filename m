From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH 2/2] refactor full duplex flow control resolution
Date: Tue, 16 Dec 2008 02:00:58 -0800 (PST)
Message-ID: <20081216.020058.57036896.davem@davemloft.net>
References: <1229258301-5073-1-git-send-email-steve.glendinning@smsc.com>
	<1229258301-5073-2-git-send-email-steve.glendinning@smsc.com>
	<1229258301-5073-3-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ian.saturley@smsc.com
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34816
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752176AbYLPKA5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2008 05:00:57 -0500
In-Reply-To: <1229258301-5073-3-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Sun, 14 Dec 2008 12:38:21 +0000

> These 4 drivers have identical full duplex flow control resolution
> functions.  This patch changes them all to use one common function.
> 
> The function in question decides whether a device should enable TX and
> RX flow control in a standard way (IEEE 802.3-2005 table 28B-3), so this
> should also be useful for other drivers.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Looks fine, applied.

Thanks Steve.
