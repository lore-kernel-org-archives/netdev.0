From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 6/7] net: dsa: mv88e6xxx: rework jumbo size
 operation
Date: Thu, 8 Jun 2017 21:42:22 +0200
Message-ID: <20170608194222.GJ20216@lunn.ch>
References: <20170608190445.24443-1-vivien.didelot@savoirfairelinux.com>
 <20170608190445.24443-7-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170608190445.24443-7-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 08, 2017 at 03:04:44PM -0400, Vivien Didelot wrote:
> Marvell chips have a Jumbo Mode to set the maximum frame size (MTU).
> 
> The mv88e6xxx_ops structure is meant to contain generic functionalities,
> no driver logic. Change port_jumbo_config to port_set_jumbo_size setting
> the mode from a given maximum size value.
> 
> There is no functional changes since we still use 10240 bytes.
> 
> At the same time, correctly clear all Jumbo Mode bits before writing.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
