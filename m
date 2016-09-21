From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: handle multiple ports in
 ATU
Date: Wed, 21 Sep 2016 00:05:10 -0400 (EDT)
Message-ID: <20160921.000510.608510333412427143.davem@davemloft.net>
References: <20160919235611.31975-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160919235611.31975-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Mon, 19 Sep 2016 19:56:11 -0400

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
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
