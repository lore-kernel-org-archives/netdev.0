From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 2/2] net: systemport: pad packets to a
 minimum of 64 bytes
Date: Wed, 07 May 2014 16:00:17 -0400 (EDT)
Message-ID: <20140507.160017.522180583853675022.davem@davemloft.net>
References: <1399317652-20078-1-git-send-email-f.fainelli@gmail.com>
	<1399317652-20078-3-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51331 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751192AbaEGUAS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 May 2014 16:00:18 -0400
In-Reply-To: <1399317652-20078-3-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Mon,  5 May 2014 12:20:52 -0700

> The switch fabric which is used behind the Broadcom SYSTEMPORT Ethernet
> controller will discard any incoming packet that is not 64 bytes or
> more. Since the UniMAC hardware automatically pads up to the specified
> length, we can simply ensure we instruct it to transmit >= 64 bytes
> packets.
> 
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Please resubmit with an adjusted commit log as discussed in this
thread, thanks.
