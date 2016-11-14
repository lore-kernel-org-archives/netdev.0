From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: Debugging Ethernet issues
Date: Mon, 14 Nov 2016 14:34:28 +0100
Message-ID: <20161114133428.GF26710@lunn.ch>
References: <5827AD4A.7010908@free.fr>
 <20161113030919.GA2892@lunn.ch>
 <5828C452.6050808@free.fr>
 <9d1f28a7-959b-fdde-3403-f6da5f521125@gmail.com>
 <5829BBFC.7040800@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        netdev <netdev@vger.kernel.org>, Mans Rullgard <mans@mansr.com>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Tom Lendacky <thomas.lendacky@amd.com>,
        Zach Brown <zach.brown@ni.com>,
        Shaohui Xie <shaohui.xie@nxp.com>,
        Tim Beale <tim.beale@alliedtelesis.co.nz>,
        Brian Hill <brian@houston-radar.com>,
        Vince Bridgers <vbridgers2013@gmail.com>,
        Balakumaran Kannan <kumaran.4353@gmail.com>,
        "David S. Miller" <davem@davemloft.net>,
        Sebastian Frias <sf84@laposte.net>,
        Kirill Kapranov <kapranoff@inbox.ru>
To: Mason <slash.tmp@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:37805 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752073AbcKNNef (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 14 Nov 2016 08:34:35 -0500
Content-Disposition: inline
In-Reply-To: <5829BBFC.7040800@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> How exactly does one use the generic PHY driver?

If there is no specific driver available for the PHY, linux will fall
back to the generic driver. So just don't compile the specific driver.
You can see under /sys/bus/mdio_bus/devices which driver is being
used.

	Andrew
