From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v3 0/5] net: dsa: remove .set_addr
Date: Mon, 16 Oct 2017 16:30:34 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD00980E8@AcuExch.aculab.com>
References: <20171013181809.14627-1-vivien.didelot@savoirfairelinux.com>
 <CY1PR0401MB1536F870727AFA21BFC31115924F0@CY1PR0401MB1536.namprd04.prod.outlook.com>
 <20171016160941.GA13339@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: 'Andrew Lunn' <andrew@lunn.ch>,
        Rodney Cummings <rodney.cummings@ni.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out6.electric.net ([192.162.217.185]:64034 "EHLO
        smtp-out6.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756205AbdJPQah (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 12:30:37 -0400
In-Reply-To: <20171016160941.GA13339@lunn.ch>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn
> Sent: 16 October 2017 17:10
...
> So, received Pause frames never leave the MAC. They don't get bridged,
> nor do they get passed up for host processing. They are purely point
> to point between two MAC peers. The destination is unambiguous. It is
> simple the other MAC peer. The destination address makes it clear it
> is a pause frame, the the source address seems to be unneeded.
> 
> In this context, a random MAC addresses are safe.

Is there any reason why a fixed value (say 00:00:00:00:00:00)
can't be used?

> In the more general case, i would agree with you. Collisions are
> possible, causing problems.

For IP MAC addresses only go as far as the first router.
So the duplicates would (typically) have to be within the same subnet.
This makes the chance of a duplicate random address unlikely.

(Unless you have an un-subnetted class A network consisting of
multiple 1km long coax segments connected by 1km long repeaters
making a single collision domain.)

	David
