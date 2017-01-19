From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] net: add regs attribute to phy device for user diagnose
Date: Thu, 19 Jan 2017 02:01:42 +0100
Message-ID: <20170119010142.GB26959@lunn.ch>
References: <20170115172150.GC5643@lunn.ch>
 <1484571579.3374.4.camel@163.com>
 <cf3e3125-582f-8b91-9c23-05dbdd2c6d24@gmail.com>
 <20170116.165401.1642553705400599921.davem@davemloft.net>
 <8729016553E3654398EA69218DA29EEF15A58E63@cnshjmbx04>
 <9ace94d7-0a3b-ff5f-63e1-53496e1e6b1b@neratec.com>
 <8729016553E3654398EA69218DA29EEF15A5A289@cnshjmbx04>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        David Miller <davem@davemloft.net>,
        "f.fainelli@gmail.com" <f.fainelli@gmail.com>,
        "cugyly@163.com" <cugyly@163.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37599 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751585AbdASBBx (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 20:01:53 -0500
Content-Disposition: inline
In-Reply-To: <8729016553E3654398EA69218DA29EEF15A5A289@cnshjmbx04>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I will add two ethtool command in kernel to read and write register in PHY. 

Write access will get NACKed by me. Read only please.

> ethtool can use these command to dump what user want, there is no
> more work to PHY driver.

Please think about how you handle PHYs with pages. This needs to be
part of the API.

     Andrew
