From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6 v3] net: factorize sync-rcu call in
 unregister_netdevice_many
Date: Thu, 16 Dec 2010 14:04:17 -0800 (PST)
Message-ID: <20101216.140417.229760449.davem@davemloft.net>
References: <1292280247-9889-1-git-send-email-opurdila@ixiacom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lucian.grijincu@gmail.com,
	ddvlad@rosedu.org
To: opurdila@ixiacom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48197
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753883Ab0LPWDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Dec 2010 17:03:48 -0500
In-Reply-To: <1292280247-9889-1-git-send-email-opurdila@ixiacom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Octavian Purdila <opurdila@ixiacom.com>
Date: Tue, 14 Dec 2010 00:44:07 +0200

> Add dev_close_many and dev_deactivate_many to factorize another
> sync-rcu operation on the netdevice unregister path.
> 
> $ modprobe dummy numdummies=10000
> $ ip link set dev dummy* up
> $ time rmmod dummy
> 
> Without the patch           With the patch
> 
> real    0m 24.63s           real    0m 5.15s
> user    0m 0.00s            user    0m 0.00s
> sys     0m 6.05s            sys     0m 5.14s
> 
> Signed-off-by: Octavian Purdila <opurdila@ixiacom.com>

I'll apply this, thanks Octavian.
