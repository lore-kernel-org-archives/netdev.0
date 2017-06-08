From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 1/7] net: dsa: mv88e6xxx: provide printing macros
Date: Thu, 8 Jun 2017 21:37:13 +0200
Message-ID: <20170608193713.GG20216@lunn.ch>
References: <20170608190445.24443-1-vivien.didelot@savoirfairelinux.com>
 <20170608190445.24443-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170608190445.24443-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 03:04:39PM -0400, Vivien Didelot wrote:
> The mv88e6xxx driver accesses a port's netdev mostly for printing.
> 
> This is bad for 2 reasons: DSA and CPU ports do not have a netdev
> pointer; it doesn't give us a correct picture of why a DSA driver might
> need to access a port's netdev.
> 
> Introduce mv88e6xxx_{dbg,err,warn} macros to print messages with a
> prefix containing the real switch name (not the compatible one),
> as well as the switch and port indexes.

Hi Vivien

I agree with the principle, but wonder about the naming. We have some
stuff which is not per port, but at the chip level. It would be nice
to have a similar set of helpers, but which only take chip. So maybe
we want to call these mv88e6xxx_port_{dbg, err, warn} and later add
mv88e6xxx_chip_{dbg, err, warn}.

   Andrew
