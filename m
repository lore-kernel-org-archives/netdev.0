From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: assign default CPU port to all ports
Date: Thu, 15 Jun 2017 17:23:52 -0400 (EDT)
Message-ID: <20170615.172352.714605650422622509.davem@davemloft.net>
References: <20170615190654.5927-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch,
        jcobham@questertangent.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170615190654.5927-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 15 Jun 2017 15:06:54 -0400

> The current code only assigns the default cpu_dp to all user ports of
> the switch to which the CPU port belongs. The user ports of the other
> switches of the fabric thus don't have a default CPU port.
> 
> This patch fixes this by assigning the cpu_dp of all user ports of all
> switches of the fabric when the tree is fully parsed.
> 
> Fixes: a29342e73911 ("net: dsa: Associate slave network device with CPU port")
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks.
