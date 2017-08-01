From: Andrew Lunn <andrew@lunn.ch>
Subject: Re: [PATCH net-next v2 07/11] net: dsa: mv88e6xxx: call phy_init_eee
Date: Tue, 1 Aug 2017 23:03:12 +0200
Message-ID: <20170801210312.GO23157@lunn.ch>
References: <20170801203241.22294-1-vivien.didelot@savoirfairelinux.com>
 <20170801203241.22294-8-vivien.didelot@savoirfairelinux.com>
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
In-Reply-To: <20170801203241.22294-8-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Aug 01, 2017 at 04:32:37PM -0400, Vivien Didelot wrote:
> It is safer to init the EEE before the DSA layer call
> phy_ethtool_set_eee, as sf2 and qca8k are doing.

I can understand making all the drivers do the same thing, but the
next patch deletes this change, making is pointless.

My preference would be to drop this. But it is not a strong preference.

  Andrew
