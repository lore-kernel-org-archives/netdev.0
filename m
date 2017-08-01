From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 01/11] net: dsa: PHY device is mandatory for
 EEE
Date: Tue, 1 Aug 2017 23:00:53 +0200
Message-ID: <20170801210053.GN23157@lunn.ch>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
 <20170801203241.22294-2-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        John Crispin <john@phrozen.org>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170801203241.22294-2-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 04:32:31PM -0400, Vivien Didelot wrote:
> The port's PHY and MAC are both implied in EEE. The current code does
> not call the PHY operations if the related device is NULL. Change that
> by returning -ENODEV if there's no PHY device attached to the interface.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
