From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: FEC on i.MX 7 transmit queue timeout
Date: Fri, 5 May 2017 14:23:30 +0200
Message-ID: <20170505122330.GA23432@lunn.ch>
References: <86b63ee28acfff3426c4a0bf72d848c1@agner.ch>
 <2bdd64ab-5644-e0a0-9bfe-b8dd2fca7abb@nxp.com>
 <80191e7c9df5871cd450f13b9ea47a10@agner.ch>
 <ab1fc814-4a81-9eb0-b20b-2cd325158ba8@nxp.com>
 <e366479239b66ba80415b5594def2369@agner.ch>
 <AM4PR0401MB2260F011313883C522EA7684FFEA0@AM4PR0401MB2260.eurprd04.prod.outlook.com>
 <e044b850a90e7112028cc12977d15cf2@agner.ch>
 <e739d361-c20f-0de1-cdd1-c9aa13a0d11a@nxp.com>
 <110a7a48649cfcbbee46340c230e9008@agner.ch>
 <46a27329-36df-1eaf-1321-24db037842fe@nxp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stefan Agner <stefan@agner.ch>,
        "festevam@gmail.com" <festevam@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "netdev-owner@vger.kernel.org" <netdev-owner@vger.kernel.org>
To: Andy Duan <fugang.duan@nxp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:51400 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752533AbdEEMXj (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 5 May 2017 08:23:39 -0400
Content-Disposition: inline
In-Reply-To: <46a27329-36df-1eaf-1321-24db037842fe@nxp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No, it is not workaround. As i said, quque1 and queue2 are for AVB paths 
> have higher priority in transmition.

Does this higher priority result in the low priority queue being
starved? Is that why the timer goes off? What happens when somebody
does use AVB. Are we back to the same problem? This is what seems to
make is sounds like a work around, not a fix.

     Andrew
