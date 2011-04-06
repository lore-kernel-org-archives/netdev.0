From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc911x: fix mac_lock acquision before calling
 smsc911x_mac_read
Date: Wed, 06 Apr 2011 12:23:14 -0700 (PDT)
Message-ID: <20110406.122314.112606688.davem@davemloft.net>
References: <1302022369-24285-1-git-send-email-eballetbo@iseebcn.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@smsc.com, netdev@vger.kernel.org
To: eballetbo@iseebcn.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44802
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753888Ab1DFTXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 15:23:50 -0400
In-Reply-To: <1302022369-24285-1-git-send-email-eballetbo@iseebcn.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Enric Balletbo i Serra <eballetbo@iseebcn.com>
Date: Tue,  5 Apr 2011 18:52:49 +0200

> When SMSC911X_SAVE_MAC_ADDRESS flag is enabled the driver calls
> smsc911x_mac_read and smsc911x_mac_read function without acquiring mac_lock
> spinlock
> 
> This patch fixes following warning
 ...
> Signed-off-by: Enric Balletbo i Serra <eballetbo@iseebcn.com>

Applied, thank you.
