From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 0/4] net: dsa: add port fast ageing
Date: Fri, 23 Sep 2016 01:43:52 +0200
Message-ID: <20160922234352.GF27769@lunn.ch>
References: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
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
In-Reply-To: <20160922204924.16229-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 22, 2016 at 04:49:20PM -0400, Vivien Didelot wrote:
> Today the DSA drivers are in charge of flushing the MAC addresses
> associated to a port when its STP state changes from Learning or
> Forwarding, to Disabled or Blocking or Listening.
> 
> This makes the drivers more complex and hides this generic switch logic.
> 
> This patchset introduces a new optional port_fast_age operation to
> dsa_switch_ops, to move this logic to the DSA layer and keep drivers
> simple. b53 and mv88e6xxx are updated accordingly.

Reviewed-by: Andrew Lunn <andrew@lunn.ch>

    Andrew
