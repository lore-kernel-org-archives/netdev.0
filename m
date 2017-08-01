From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 09/11] net: dsa: remove PHY device argument
 from .set_eee
Date: Tue, 1 Aug 2017 23:06:26 +0200
Message-ID: <20170801210626.GQ23157@lunn.ch>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
 <20170801203241.22294-10-vivien.didelot@savoirfairelinux.com>
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
In-Reply-To: <20170801203241.22294-10-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 04:32:39PM -0400, Vivien Didelot wrote:
> The DSA switch operations for EEE are only meant to configure a port's
> MAC EEE settings. The port's PHY EEE settings are accessed by the DSA
> layer and must be made available via a proper PHY driver.
> 
> In order to reduce this confusion, remove the phy_device argument from
> the .set_eee operation.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
