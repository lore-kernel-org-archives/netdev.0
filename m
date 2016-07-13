From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v3 0/2] net: ethoc: Error path and transmit fixes
Date: Tue, 12 Jul 2016 23:13:27 -0700 (PDT)
Message-ID: <20160712.231327.2024249388377280454.davem@davemloft.net>
References: <1468364676-19242-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jcmvbkbc@gmail.com,
	colin.king@canonical.com, tklauser@distanz.ch,
	thierry.reding@gmail.com, andrew@lunn.ch
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57308 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750816AbcGMGNj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2016 02:13:39 -0400
In-Reply-To: <1468364676-19242-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 12 Jul 2016 16:04:34 -0700

> This patch series contains two patches for the ethoc driver while testing on a
> TS-7300 board where ethoc is provided by an on-board FPGA.
> 
> First patch was cooked after chasing crashes with invalid resources passed to
> the driver.
> 
> Second patch was cooked after seeing that an interface configured with IP
> 192.168.2.2 was sending ARP packets for 192.168.0.0, no wonder why it could not
> work.
> 
> I don't have access to any other platform using an ethoc interface so
> it could be good to some testing on Xtensa for instance.

Series applied, thanks Florian.
