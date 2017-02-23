From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: create drivers/net/mdio and move mdio drivers into it
Date: Thu, 23 Feb 2017 00:10:27 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15A81CEB@cnshjmbx02>
References: <8729016553E3654398EA69218DA29EEF15A7E753@cnshjmbx02>
 <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A807CA@cnshjmbx02>
 <dfde5fbd-e4de-7b6d-37a6-dba1720cc3d9@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A80800@cnshjmbx02>
 <119144e3-d42e-e4dd-d95d-624e4816cbe3@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A81861@cnshjmbx02>
 <20170222102109.GB18705@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:64820 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S934171AbdBWAL6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Feb 2017 19:11:58 -0500
In-Reply-To: <20170222102109.GB18705@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Andrew Lunn [mailto:andrew@lunn.ch]
> Sent: Wednesday, February 22, 2017 6:21 PM
> To: YUAN Linyu
> Cc: Florian Fainelli; David S . Miller; netdev@vger.kernel.org; cugyly@163.com
> Subject: Re: create drivers/net/mdio and move mdio drivers into it
> 
> On Wed, Feb 22, 2017 at 05:38:49AM +0000, YUAN Linyu wrote:
> > Hi Florian,
> >
> > 1.
> > Let's go back to original topic,
> > Can we move all mdio dirvers into drivers/net/mdio ?
> 
> Hi Yuan
> 
> Please could you explain what benefit this brings. Please also list
> all the downsides for such a move. As Florian said, we need to ensure
> such a move adds more value than it removes.
At beginning I think mdio and phy are two different things, mdio should have it's home.

> 
> > Per may understanding,
> > I don't know why create a struct mii_bus instance to represent a mdio device
> in current mdio driver.
> > Why not create a struct mdio_device instance, it's easy to understand.
> > (We can move part of member of mii_bus to mdio_device).
> 
> Please take a step back. What are you trying to achieve. What is the
> big picture. What cannot you do with the current design?
Big picture is we can remove struct mii_bus, and use struct mdio_device/driver for mdio controller.

> 
>     Andrew
