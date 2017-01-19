From: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Subject: RE: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Thu, 19 Jan 2017 00:45:56 +0000
Message-ID: <8729016553E3654398EA69218DA29EEF15A5A289@cnshjmbx04>
References: <20170115172150.GC5643@lunn.ch>
 <1484571579.3374.4.camel@163.com>
 <cf3e3125-582f-8b91-9c23-05dbdd2c6d24@gmail.com>
 <20170116.165401.1642553705400599921.davem@davemloft.net>
 <8729016553E3654398EA69218DA29EEF15A58E63@cnshjmbx04>
 <9ace94d7-0a3b-ff5f-63e1-53496e1e6b1b@neratec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "cugyly@163.com" <cugyly@163.com>,
        "andrew@lunn.ch" <andrew@lunn.ch>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        David Miller <davem@davemloft.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cnshjsmin03.alcatel-sbell.com.cn ([116.246.26.71]:42972 "EHLO
        cnshjsmin03.alcatel-sbell.com.cn" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751439AbdASBDl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Jan 2017 20:03:41 -0500
In-Reply-To: <9ace94d7-0a3b-ff5f-63e1-53496e1e6b1b@neratec.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Zefir Kurtisi [mailto:zefir.kurtisi@neratec.com]
> 
> ... on the other hand, having direct RW access to MDIO regs can ease your life
> greatly during bring-up / debugging of PHYs.
> 
> Attached is a patch we are using to track down PHY problems at register level,
> not
> for integrating into the kernel but as a handy tool for developers.
> 

We should follow previous discussion and move this debug feature to ethtool.
Sysfs is not suggested by experts. I think it's reasonable and it's netdev development way.

One thing that your patch only care a few registers.
It's better to find a way to check all register of PHY.

I will add two ethtool command in kernel to read and write register in PHY. 
ethtool can use these command to dump what user want, there is no more work to PHY driver.


(
additional, mii-tool have two ioctl command[SIOCSMIIREG, SIOCGMIIREG], 
but is not export to use in mii-tool.
It's better to add command to eth-tool which maintained closely with kernel.
)

> 
> Cheers,
> Zefir
> 
