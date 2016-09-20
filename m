From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: handle multiple ports in
 ATU
Date: Tue, 20 Sep 2016 02:41:29 +0200
Message-ID: <20160920004129.GA8026@lunn.ch>
References: <20160919235611.31975-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160919235611.31975-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 19, 2016 at 07:56:11PM -0400, Vivien Didelot wrote:
> An address can be loaded in the ATU with multiple ports, for instance
> when adding multiple ports to a Multicast group with "bridge mdb".
> 
> The current code doesn't allow that. Add an helper to get a single entry
> from the ATU, then set or clear the requested port, before loading the
> entry back in the ATU.
> 
> Note that the required _mv88e6xxx_atu_getnext function is defined below
> mv88e6xxx_port_db_load_purge, so forward-declare it for the moment. The
> ATU code will be isolated in future patches.
> 
> Fixes: 83dabd1fa84c ("net: dsa: mv88e6xxx: make switchdev DB ops generic")

Is this a real fixes? You don't make it clear what goes wrong. I
assume adding the same MAC address for a second time but for a
different port removes the first entry for the old port?

> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
