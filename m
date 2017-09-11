From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH v1 net] smsc95xx: Configure pause time to 0xffff when tx
 flow control enabled
Date: Mon, 11 Sep 2017 16:02:20 +0200
Message-ID: <20170911140220.GC27599@lunn.ch>
References: <CE371C1263339941885964188A0225FA335A6F@CHN-SV-EXMX03.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, steve.glendinning@shawell.net
To: Nisar.Sayed@microchip.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37186 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750969AbdIKOCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 11 Sep 2017 10:02:25 -0400
Content-Disposition: inline
In-Reply-To: <CE371C1263339941885964188A0225FA335A6F@CHN-SV-EXMX03.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 11, 2017 at 12:32:10PM +0000, Nisar.Sayed@microchip.com wrote:
> From: Nisar Sayed <Nisar.Sayed@microchip.com>
> 
> Configure pause time to 0xffff when tx flow control enabled
> 
> Set pause time to 0xffff in the pause frame to indicate the
> partner to stop sending the packets. When RX buffer frees up,
> the device sends pause frame with pause time zero for partner to
> resume transmission.

Hi Nisar

Thanks for the updated description. Since you are posting this for
net, not net-next, could you add a fixes: tag?

Thanks
	Andrew
