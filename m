From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 5/7] net: dsa: mv88e6xxx: rework pause limit
 operation
Date: Thu, 8 Jun 2017 21:40:54 +0200
Message-ID: <20170608194054.GI20216@lunn.ch>
References: <20170608190445.24443-1-vivien.didelot@savoirfairelinux.com>
 <20170608190445.24443-6-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170608190445.24443-6-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 03:04:43PM -0400, Vivien Didelot wrote:
> All Marvell chips supporting Pause frames limiting use 1-byte value for
> input and output.
> 
> Old chips have both bytes adjacent in a 16-bit register. New ones have
> an indirect table using 8-bit data.
> 
> The mv88e6xxx library functions (such as in port.c) must not contain
> driver logic, but only generic helpers. This patch changes the
> port_pause_config operation for port_pause_limit taking two u8 arguments
> for input and output limits. There is no functional changes.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
