From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] smsc95xx: Configure pause time to 0xffff when
 tx flow control enabled
Date: Tue, 12 Sep 2017 20:36:49 -0700 (PDT)
Message-ID: <20170912.203649.1370203318245275222.davem@davemloft.net>
References: <CE371C1263339941885964188A0225FA335B8D@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: UNGLinuxDriver@microchip.com, netdev@vger.kernel.org,
        steve.glendinning@shawell.net
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37074 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751479AbdIMDgw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 23:36:52 -0400
In-Reply-To: <CE371C1263339941885964188A0225FA335B8D@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Nisar.Sayed@microchip.com>
Date: Mon, 11 Sep 2017 17:43:11 +0000

> From: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> Configure pause time to 0xffff when tx flow control enabled
> 
> Set pause time to 0xffff in the pause frame to indicate the
> partner to stop sending the packets. When RX buffer frees up,
> the device sends pause frame with pause time zero for partner to
> resume transmission.
> 
> Fixes: 2f7ca802bdae ("Add SMSC LAN9500 USB2.0 10/100 ethernet adapter driver")
> Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>

Applied.
