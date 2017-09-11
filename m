From: <Nisar.Sayed@microchip.com>
Subject: RE: [PATCH v1 net] smsc95xx: Configure pause time to 0xffff when tx
 flow control enabled
Date: Mon, 11 Sep 2017 17:38:07 +0000
Message-ID: <CE371C1263339941885964188A0225FA335B5C@CHN-SV-EXMX03.mchp-main.com>
References: <CE371C1263339941885964188A0225FA335A6F@CHN-SV-EXMX03.mchp-main.com>
 <20170911140220.GC27599@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <davem@davemloft.net>, <UNGLinuxDriver@microchip.com>,
        <netdev@vger.kernel.org>, <steve.glendinning@shawell.net>
To: <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from esa6.microchip.iphmx.com ([216.71.154.253]:27977 "EHLO
        esa6.microchip.iphmx.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750983AbdIKRiZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 11 Sep 2017 13:38:25 -0400
In-Reply-To: <20170911140220.GC27599@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> On Mon, Sep 11, 2017 at 12:32:10PM +0000, Nisar.Sayed@microchip.com
> wrote:
> > From: Nisar Sayed <Nisar.Sayed@microchip.com>
> >
> > Configure pause time to 0xffff when tx flow control enabled
> >
> > Set pause time to 0xffff in the pause frame to indicate the partner to
> > stop sending the packets. When RX buffer frees up, the device sends
> > pause frame with pause time zero for partner to resume transmission.
> 
> Hi Nisar
> 
> Thanks for the updated description. Since you are posting this for net, not
> net-next, could you add a fixes: tag?
> 
> Thanks
> 	Andrew

Thanks Andrew, yes I will add and will submit next revision

- Nisar
