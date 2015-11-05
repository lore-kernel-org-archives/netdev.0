From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: isolate unbridged ports
Date: Thu, 05 Nov 2015 13:37:41 -0500 (EST)
Message-ID: <20151105.133741.920416694054745930.davem@davemloft.net>
References: <1446675820-25608-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446675820-25608-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Wed,  4 Nov 2015 17:23:40 -0500

> The DSA documentation specifies that each port must be capable of
> forwarding frames to the CPU port. The last changes on bridging support
> for the mv88e6xxx driver broke this requirement for non-bridged ports.
> 
> So as for the bridged ports, reserve a few VLANs (4000+) in the switch
> to isolate ports that have not been bridged yet.
> 
> By default, a port will be isolated with the CPU and DSA ports. When the
> port joins a bridge, it will leave its reserved port. When it is removed
> from a bridge, it will join its reserved VLAN again.
> 
> Fixes: 5fe7f68016ff ("net: dsa: mv88e6xxx: fix hardware bridging")
> Reported-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied, thanks Vivien.
