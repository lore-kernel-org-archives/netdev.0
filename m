From: Stefan Chulski <stefanc@marvell.com>
Subject: RE: [EXT] Re: [PATCH net-next 03/18] net: mvpp2: set the SMI PHY
 address when connecting to the PHY
Date: Wed, 23 Aug 2017 13:30:47 +0000
Message-ID: <7dc117f56c284081b791bceb588a8aa1@IL-EXCH01.marvell.com>
References: <20170724134848.19330-1-antoine.tenart@free-electrons.com>
 <20170724134848.19330-4-antoine.tenart@free-electrons.com>
 <20170726160806.GF12049@lunn.ch> <20170728014905.GC24728@kwain>
 <20170728042153.GH18666@lunn.ch>
 <f6d8907b057241c7a72da0a0255cfd23@IL-EXCH01.marvell.com>
 <20170823123424.GA28612@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Antoine Tenart <antoine.tenart@free-electrons.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "jason@lakedaemon.net" <jason@lakedaemon.net>,
        "gregory.clement@free-electrons.com"
        <gregory.clement@free-electrons.com>,
        "sebastian.hesselbarth@gmail.com" <sebastian.hesselbarth@gmail.com>,
        "thomas.petazzoni@free-electrons.com"
        <thomas.petazzoni@free-electrons.com>,
        Nadav Haklai <nadavh@marvell.com>,
        "linux@armlinux.org.uk" <linux@armlinux.org.uk>,
        "mw@semihalf.com" <mw@semihalf.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-arm-kernel@lists.infradead.org"
        <linux-arm-kernel@lists.infradead.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-0016f401.pphosted.com ([67.231.156.173]:48348 "EHLO
        mx0b-0016f401.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1753973AbdHWNbj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 09:31:39 -0400
In-Reply-To: <20170823123424.GA28612@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> In order to safely read/write the PHY, you need to hold the PHY mutex.
> Unless the hardware is very smart, please don't enable this. Let the phylib and
> the appropriate PHY driver do the work.
> 
>        Andrew

Hi Andrew,

This feature work only for Out-of-Band Auto-Negotiation in SGMII Mode.
Current GoP(MAC) code configure SGMII In-band Auto-Negotiation performed by the PCS layer
without PHY polling.

Regards,
Stefan. 
