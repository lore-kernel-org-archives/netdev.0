From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: create drivers/net/mdio and move mdio drivers into it
Date: Mon, 20 Feb 2017 06:29:23 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15A80800@cnshjmbx02>
References: <8729016553E3654398EA69218DA29EEF15A7E753@cnshjmbx02>
 <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
 <8729016553E3654398EA69218DA29EEF15A807CA@cnshjmbx02>
 <dfde5fbd-e4de-7b6d-37a6-dba1720cc3d9@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:51269 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750939AbdBTG30 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 01:29:26 -0500
In-Reply-To: <dfde5fbd-e4de-7b6d-37a6-dba1720cc3d9@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Florian Fainelli [mailto:f.fainelli@gmail.com]
> Sent: Monday, February 20, 2017 1:42 PM
> To: YUAN Linyu; David S . Miller; Andrew Lunn
> Cc: netdev@vger.kernel.org; cugyly@163.com
> Subject: Re: create drivers/net/mdio and move mdio drivers into it
> > 4. support mdio auto probe phy device.
> 
> That's already the case, even in a Device Tree enabled system if you
> omit to provide a "reg" property for child nodes, the bus is
> automatically scanned.
> 
I check of_mdiobus_registe() which not do auto scan.
Which function should I refer?
