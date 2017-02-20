From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: create drivers/net/mdio and move mdio drivers into it
Date: Sun, 19 Feb 2017 21:03:22 -0800
Message-ID: <afdb9ff7-afa9-47b0-0e84-396080fe0867@gmail.com>
References: <8729016553E3654398EA69218DA29EEF15A7E753@cnshjmbx02>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "cugyly@163.com" <cugyly@163.com>
To: YUAN Linyu <Linyu.Yuan@alcatel-sbell.com.cn>,
        "David S . Miller" <davem@davemloft.net>,
        Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36270 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750777AbdBTFDw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Feb 2017 00:03:52 -0500
Received: by mail-pg0-f68.google.com with SMTP id a123so8577313pgc.3
        for <netdev@vger.kernel.org>; Sun, 19 Feb 2017 21:03:25 -0800 (PST)
In-Reply-To: <8729016553E3654398EA69218DA29EEF15A7E753@cnshjmbx02>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 02/19/2017 04:20 PM, YUAN Linyu wrote:
> Hi,
> 
> I have an idea to create drivers/net/mdio and move mdio drivers(drivers/net/phy/mdio-* | drivers/net/ethernet/xxx/mdio-yyy | ) into it.
> 
> Do you think it is acceptable ?

What problem are you trying to fix by doing such a move? Moving files
around mean that making stable backports are going to be much more painful.

So without further explanation, does not sound like such a great idea.
-- 
Florian
