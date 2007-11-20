From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 11/11] netpoll: rx use RCU
Date: Mon, 19 Nov 2007 20:00:40 -0800 (PST)
Message-ID: <20071119.200040.144136236.davem@davemloft.net>
References: <20071103184314.216145305@linux-foundation.org>
	<20071103184339.039313598@linux-foundation.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: satyam@infradead.org, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:36979
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756933AbXKTEAl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Nov 2007 23:00:41 -0500
In-Reply-To: <20071103184339.039313598@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Sat, 03 Nov 2007 11:43:25 -0700

> Get rid of rx_lock and use Read-Copy-Update to make sure
> that netpoll info and rx handle are not used after free.
> 
> Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

Please also respin this one too, thanks.
