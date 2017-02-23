From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: create drivers/net/mdio and move mdio drivers into it
Date: Thu, 23 Feb 2017 09:51:17 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15A81F13@cnshjmbx02>
References: <8729016553E3654398EA69218DA29EEF15A7E753@cnshjmbx02>
 <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A807CA@cnshjmbx02>
 <dfde5fbd-e4de-7b6d-37a6-dba1720cc3d9@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A80800@cnshjmbx02>
 <119144e3-d42e-e4dd-d95d-624e4816cbe3@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A81861@cnshjmbx02>
 <20170222102109.GB18705@lunn.ch>
 <8729016553E3654398EA69218DA29EEF15A81CEB@cnshjmbx02>
 <20170223093019.GB13517@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:52332 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751107AbdBWJvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 04:51:20 -0500
In-Reply-To: <20170223093019.GB13517@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
> On Behalf Of Andrew Lunn
> Sent: Thursday, February 23, 2017 5:30 PM
> To: YUAN Linyu
> Cc: Florian Fainelli; David S . Miller; netdev@vger.kernel.org; cugyly@163.com
> Subject: Re: create drivers/net/mdio and move mdio drivers into it
> 
> > Big picture is we can remove struct mii_bus,
> 
> So if you remove this, how do you represent MII as a bus? It is a bus,
> clause 22 allows up to 32 devices on it, and i have boards with more
> than 8 devices on the bus. Clause 44 allows many more devices on the
> bus.
> 
add a phy device list to mdio_device.
> 	Andrew
