From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: create drivers/net/mdio and move mdio drivers into it
Date: Thu, 23 Feb 2017 11:29:49 +0100
Message-ID: <20170223102949.GB14312@lunn.ch>
References: <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A807CA@cnshjmbx02>
 <dfde5fbd-e4de-7b6d-37a6-dba1720cc3d9@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A80800@cnshjmbx02>
 <119144e3-d42e-e4dd-d95d-624e4816cbe3@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A81861@cnshjmbx02>
 <20170222102109.GB18705@lunn.ch>
 <8729016553E3654398EA69218DA29EEF15A81CEB@cnshjmbx02>
 <20170223093019.GB13517@lunn.ch>
 <8729016553E3654398EA69218DA29EEF15A81F13@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:49900 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751023AbdBWLkS (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 23 Feb 2017 06:40:18 -0500
Content-Disposition: inline
In-Reply-To: <8729016553E3654398EA69218DA29EEF15A81F13@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 23, 2017 at 09:51:17AM +0000, YUAN Linyu wrote:
> 
> 
> > -----Original Message-----
> > From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> > On Behalf Of Andrew Lunn
> > Sent: Thursday, February 23, 2017 5:30 PM
> > To: YUAN Linyu
> > Cc: Florian Fainelli; David S . Miller; netdev@vger.kernel.org; cugyly@163.com
> > Subject: Re: create drivers/net/mdio and move mdio drivers into it
> > 
> > > Big picture is we can remove struct mii_bus,
> > 
> > So if you remove this, how do you represent MII as a bus? It is a bus,
> > clause 22 allows up to 32 devices on it, and i have boards with more
> > than 8 devices on the bus. Clause 44 allows many more devices on the
> > bus.
> > 
> add a phy device list to mdio_device.

Hi Yuan

And where do you put the bus name? The bus operations? The mutex for
accessing devices on the bus? The bus is a device, so you need a
device structure somewhere, to make it part of the device
hierarchy. Where do you put that?

I think it is time to stop this discussion, and you need to submit
patches we can review, how you think this would work. That will make
you look at the details.

	Andrew
