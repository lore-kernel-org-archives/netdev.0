From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 9/9] net: dsa: mv88e6xxx: add cross-chip
 bridging
Date: Fri, 31 Mar 2017 18:39:49 +0200
Message-ID: <20170331163949.GI12814@lunn.ch>
References: <20170330213715.9666-1-vivien.didelot@savoirfairelinux.com>
 <20170330213715.9666-10-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170330213715.9666-10-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 30, 2017 at 05:37:15PM -0400, Vivien Didelot wrote:
> Implement the DSA cross-chip bridging operations by remapping the local
> ports an external source port can egress frames to, when this cross-chip
> port joins or leaves a bridge.
> 
> The PVT is no longer configured with all ones allowing any external
> frame to egress any local port. Only DSA and CPU ports, as well as
> bridge group members, can egress frames on local ports.

Hi Vivien

With the ZII devel B, we have two switches with PVT, and one
without. What happens in this setup? Can the non-PVT switch leak
frames out user ports which should otherwise be blocked?

Thanks
	Andrew
