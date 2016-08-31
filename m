From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/3] net: dsa: mv88e6xxx: make switchdev DB ops
 generic
Date: Wed, 31 Aug 2016 16:53:03 +0200
Message-ID: <20160831145303.GE15078@lunn.ch>
References: <20160829203246.18811-1-vivien.didelot@savoirfairelinux.com>
 <20160829203246.18811-3-vivien.didelot@savoirfairelinux.com>
 <20160831134943.GB15078@lunn.ch>
 <87shtlvw8c.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from vps0.lunn.ch ([178.209.37.122]:59808 "EHLO vps0.lunn.ch"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933835AbcHaOxG (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 31 Aug 2016 10:53:06 -0400
Content-Disposition: inline
In-Reply-To: <87shtlvw8c.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> No. mv88e6xxx_port_db_dump already exists, this is the function called
> mv88e6xxx_port_db_dump_one multiple time. Here, _one refers to an FID
> (forwarding database). 88E6352 have 4096 FIDs.

So maybe s/_one/_fid/ ?

   Andrew
