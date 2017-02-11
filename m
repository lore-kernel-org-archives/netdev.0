From: yuan linyu <cugyly@163.com>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Sat, 11 Feb 2017 11:48:18 +0800
Message-ID: <1486784898.3983.1.camel@163.com>
References: <20170115172150.GC5643@lunn.ch>
         <1484571579.3374.4.camel@163.com>
         <cf3e3125-582f-8b91-9c23-05dbdd2c6d24@gmail.com>
         <20170116.165401.1642553705400599921.davem@davemloft.net>
         <8729016553E3654398EA69218DA29EEF15A58E63@cnshjmbx04>
         <9ace94d7-0a3b-ff5f-63e1-53496e1e6b1b@neratec.com>
         <8729016553E3654398EA69218DA29EEF15A5A289@cnshjmbx04>
         <20170119010142.GB26959@lunn.ch>
Reply-To: cugyly@163.com
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8bit
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        David Miller <davem@davemloft.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>,
        YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-14.163.com ([220.181.12.14]:48870 "EHLO m12-14.163.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751716AbdBKDt2 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 10 Feb 2017 22:49:28 -0500
In-Reply-To: <20170119010142.GB26959@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 四, 2017-01-19 at 02:01 +0100, Andrew Lunn wrote:
> > 
> > I will add two ethtool command in kernel to read and write register in PHY. 
> Write access will get NACKed by me. Read only please.
some register need to write some value first then read.
if read only, it will not achieve the goal.
> 
> > 
> > ethtool can use these command to dump what user want, there is no
> > more work to PHY driver.
> Please think about how you handle PHYs with pages. This needs to be
> part of the API.
thank, I will.
> 
>      Andrew
