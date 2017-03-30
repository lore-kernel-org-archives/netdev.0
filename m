From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next 4/9] net: dsa: mv88e6xxx: allocate the number of
 ports
Date: Thu, 30 Mar 2017 15:50:50 +0200
Message-ID: <20170330135050.GD17879@lunn.ch>
References: <20170329203020.27042-1-vivien.didelot@savoirfairelinux.com>
 <20170329203020.27042-5-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20170329203020.27042-5-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 29, 2017 at 04:30:15PM -0400, Vivien Didelot wrote:
> The current code allocates DSA_MAX_PORTS ports for a Marvell dsa_switch
> structure. Provide the exact number of ports so the corresponding
> ds->num_ports is accurate.

Hi Vivien

Is net/dsa/dsa.c: dsa_switch_setup() still used?  If it is, won't that
invalidate your assumption about ds->num_ports.

   Andrew
