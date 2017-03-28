From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 3/4] net: dsa: mv88e6xxx: fix 88E6191 ops
Date: Tue, 28 Mar 2017 20:58:16 +0200
Message-ID: <20170328185816.GC2268@lunn.ch>
References: <20170328175035.13897-1-vivien.didelot@savoirfairelinux.com>
 <20170328175035.13897-4-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170328175035.13897-4-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 28, 2017 at 01:50:34PM -0400, Vivien Didelot wrote:
> The mv88e6xxx_info structure for the 88E6191 chip was pointing the
> mv88e6391_ops definition instead of mv88e6191_ops. Fix this.

mv88e6391_ops and mv88e6191_ops appear to be identical, so effectively
there is no bug here. So no need to have this in -stable.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
