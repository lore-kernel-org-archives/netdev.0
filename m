From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] smsc95xx: Support only IPv4 TCP/UDP csum offload
Date: Sun, 21 May 2017 13:32:19 -0400 (EDT)
Message-ID: <20170521.133219.666611127277983923.davem@davemloft.net>
References: <CE371C1263339941885964188A0225FA308E06@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, UNGLinuxDriver@microchip.com,
        steve.glendinning@shawell.net, popcornmix@gmail.com
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:45068 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753915AbdEURcV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 21 May 2017 13:32:21 -0400
In-Reply-To: <CE371C1263339941885964188A0225FA308E06@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: <Nisar.Sayed@microchip.com>
Date: Fri, 19 May 2017 14:00:25 +0000

> From: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> When TX checksum offload is used, if the computed checksum is 0 the
> LAN95xx device do not alter the checksum to 0xffff.  In the case of ipv4
> UDP checksum, it indicates to receiver that no checksum is calculated.
> Under ipv6, UDP checksum yields a result of zero must be changed to
> 0xffff. Hence disabling checksum offload for ipv6 packets.
> 
> Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> Reported-by: popcorn mix <popcornmix@gmail.com>

Appied, thanks.
