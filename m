From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH] smsc95xx: use ethtool_op_get_ts_info()
Date: Thu, 13 Jul 2017 18:29:13 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AD8899@CHN-SV-EXMX02.mchp-main.com>
References: <1499967657-16849-1-git-send-email-brain@jikos.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <linux-usb@vger.kernel.org>
To: <brain@jikos.cz>, <steve.glendinning@shawell.net>,
        <UNGLinuxDriver@microchip.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa5.microchip.iphmx.com ([216.71.150.166]:9632 "EHLO
        esa5.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752651AbdGMS3T (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 13 Jul 2017 14:29:19 -0400
In-Reply-To: <1499967657-16849-1-git-send-email-brain@jikos.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Petr Kulhavy [mailto:brain@jikos.cz]
> Sent: Thursday, July 13, 2017 1:41 PM
> To: steve.glendinning@shawell.net; UNGLinuxDriver
> Cc: netdev@vger.kernel.org; linux-usb@vger.kernel.org; Petr Kulhavy
> Subject: [PATCH] smsc95xx: use ethtool_op_get_ts_info()
> 
> This change enables the use of SW timestamping on Raspberry PI.
> 
> smsc95xx uses the usbnet transmit function usbnet_start_xmit(), which
> implements software timestamping. However the
> SOF_TIMESTAMPING_TX_SOFTWARE
> capability was missing and only SOF_TIMESTAMPING_RX_SOFTWARE was
> announced.
> By using ethtool_op_get_ts_info() as get_ts_info() also the
> SOF_TIMESTAMPING_TX_SOFTWARE is announced.
> 
> Signed-off-by: Petr Kulhavy <brain@jikos.cz>

Reviewed-by: Woojung Huh <Woojung.Huh@microchip.com>

Thanks
