From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: add tx checksum offload support
Date: Thu, 20 Nov 2008 04:19:31 -0800 (PST)
Message-ID: <20081120.041931.236800991.davem@davemloft.net>
References: <1227171756-4280-1-git-send-email-steve.glendinning@smsc.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ian.saturley@smsc.com, netdev@vger.kernel.org
To: steve.glendinning@smsc.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60517
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754141AbYKTMTc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Nov 2008 07:19:32 -0500
In-Reply-To: <1227171756-4280-1-git-send-email-steve.glendinning@smsc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steve Glendinning <steve.glendinning@smsc.com>
Date: Thu, 20 Nov 2008 09:02:36 +0000

> LAN9500 supports tx checksum offload, which slightly decreases cpu
> utilisation.  The benefit isn't very large because we still require
> the skb to be linearized, but it does save a few cycles.
> 
> This patch adds support for it, and enables it by default.
> 
> Signed-off-by: Steve Glendinning <steve.glendinning@smsc.com>

Applied, thanks for refreshing this against net-next-2.6
