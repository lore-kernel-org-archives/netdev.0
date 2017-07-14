From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] smsc95xx: use ethtool_op_get_ts_info()
Date: Fri, 14 Jul 2017 08:54:16 -0700 (PDT)
Message-ID: <20170714.085416.933472043840430383.davem@davemloft.net>
References: <1499967657-16849-1-git-send-email-brain@jikos.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: steve.glendinning@shawell.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: brain@jikos.cz
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36666 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753565AbdGNPyR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2017 11:54:17 -0400
In-Reply-To: <1499967657-16849-1-git-send-email-brain@jikos.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Petr Kulhavy <brain@jikos.cz>
Date: Thu, 13 Jul 2017 19:40:57 +0200

> This change enables the use of SW timestamping on Raspberry PI.
> 
> smsc95xx uses the usbnet transmit function usbnet_start_xmit(), which
> implements software timestamping. However the SOF_TIMESTAMPING_TX_SOFTWARE
> capability was missing and only SOF_TIMESTAMPING_RX_SOFTWARE was announced.
> By using ethtool_op_get_ts_info() as get_ts_info() also the
> SOF_TIMESTAMPING_TX_SOFTWARE is announced.
> 
> Signed-off-by: Petr Kulhavy <brain@jikos.cz>

Applied.
