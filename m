From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.6.25] [ATM] Oops reading net/atm/arp
Date: Thu, 10 Jan 2008 03:51:51 -0800 (PST)
Message-ID: <20080110.035151.48521188.davem@davemloft.net>
References: <20080110112853.GA16173@iris.sw.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dlezcano@fr.ibm.com, xemul@openvz.org, netdev@vger.kernel.org,
	containers@lists.osdl.org, devel@openvz.org
To: den@openvz.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59633
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752910AbYAJLv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 06:51:56 -0500
In-Reply-To: <20080110112853.GA16173@iris.sw.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Denis V. Lunev" <den@openvz.org>
Date: Thu, 10 Jan 2008 14:28:53 +0300

> cat /proc/net/atm/arp causes the NULL pointer dereference in the
> get_proc_net+0xc/0x3a. This happens as proc_get_net believes that the
> parent proc dir entry contains struct net.
> 
> Fix this assumption for "net/atm" case.
> 
> The problem is introduced by the commit c0097b07abf5f92ab135d024dd41bd2aada1512f
> from Eric W. Biederman/Daniel Lezcano.
> 
> Signed-off-by: Denis V. Lunev <den@openvz.org>

Applied, thanks.
