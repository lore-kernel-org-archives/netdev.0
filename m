From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 2/2] net: dsa: use cpu_switch instead of ds[0]
Date: Wed, 18 Jan 2017 13:50:57 +0100
Message-ID: <20170118125057.GB7690@lunn.ch>
References: <20170118014139.31417-1-vivien.didelot@savoirfairelinux.com>
 <20170118014139.31417-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170118014139.31417-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 17, 2017 at 08:41:39PM -0500, Vivien Didelot wrote:
> Now that the DSA Ethernet switches are true Linux devices, the CPU
> switch is not necessarily the first one. If its address is higher than
> the second switch on the same MDIO bus, its index will be 1, not 0.
> 
> Avoid any confusion by using dst->cpu_switch instead of dst->ds[0].
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
