From: <Nisar.Sayed@microchip.com>
Subject: RE: [PATCH v2 net] smsc95xx: Support only IPv4 TCP/UDP csum offload
Date: Tue, 23 May 2017 12:06:09 +0000
Message-ID: <CE371C1263339941885964188A0225FA30A119@CHN-SV-EXMX03.mchp-main.com>
References: <CE371C1263339941885964188A0225FA308E06@CHN-SV-EXMX03.mchp-main.com>,<20170521.133219.666611127277983923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>, <UNGLinuxDriver@microchip.com>,
        <steve.glendinning@shawell.net>, <popcornmix@gmail.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:55613 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763774AbdEWMGL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 May 2017 08:06:11 -0400
In-Reply-To: <20170521.133219.666611127277983923.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > When TX checksum offload is used, if the computed checksum is 0 the
> > LAN95xx device do not alter the checksum to 0xffff.  In the case of ipv4
> > UDP checksum, it indicates to receiver that no checksum is calculated.
> > Under ipv6, UDP checksum yields a result of zero must be changed to
> > 0xffff. Hence disabling checksum offload for ipv6 packets.
> >
> > Signed-off-by: Nisar Sayed <Nisar.Sayed@microchip.com>
> >
> > Reported-by: popcorn mix <popcornmix@gmail.com>
> 
> Appied, thanks.

Thanks.
