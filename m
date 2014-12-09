From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: systemport: allow changing MAC address
Date: Tue, 09 Dec 2014 18:26:26 -0500 (EST)
Message-ID: <20141209.182626.1677543673585216492.davem@davemloft.net>
References: <1418083158-4027-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39953 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753367AbaLIX01 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2014 18:26:27 -0500
In-Reply-To: <1418083158-4027-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  8 Dec 2014 15:59:18 -0800

> Hook a ndo_set_mac_address callback, update the internal Ethernet MAC in
> the netdevice structure, and finally write that address down to the
> UniMAC registers. If the interface is down, and most likely clock gated,
> we do not update the registers but just the local copy, such that next
> ndo_open() call will effectively write down the address.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks.
