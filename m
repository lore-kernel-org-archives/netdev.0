From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH] DSA support for Micrel KSZ8895
Date: Tue, 29 Aug 2017 14:26:04 +0200
Message-ID: <20170829122604.GA22093@lunn.ch>
References: <20170816075524.GA18532@amd>
 <20170816140451.GA13006@lunn.ch>
 <9235D6609DB808459E95D78E17F2E43D40AFF8C1@CHN-SV-EXMX02.mchp-main.com>
 <20170827123658.GA727@amd>
 <20170827163122.GG13622@lunn.ch>
 <20170828070232.GA18135@amd>
 <20170828140927.GD10418@lunn.ch>
 <CAJGZr0K46jBd9Sn4HNPgAeHTQtBuBHzX87GveAJf3_5b_WM69g@mail.gmail.com>
 <20170829074130.GA31303@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Maxim Uvarov <muvarov@gmail.com>, Woojung.Huh@microchip.com,
        nathan.leigh.conrad@gmail.com,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        Tristram.Ha@micrel.com
To: Pavel Machek <pavel@ucw.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:43010 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753794AbdH2M0L (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 08:26:11 -0400
Content-Disposition: inline
In-Reply-To: <20170829074130.GA31303@amd>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> But the MDIO emaulation code is from their driver, after lots of
> deletions.

Is this driver supposed to run on lots of different OSs? That would
explain why they ignored the Linux MDIO and PHY layers.

If possible, please make use of the Linux infrastructure.

   Andrew
