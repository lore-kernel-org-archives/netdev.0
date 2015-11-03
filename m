From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: include DSA ports in VLANs
Date: Tue, 03 Nov 2015 11:35:18 -0500 (EST)
Message-ID: <20151103.113518.611629631978527699.davem@davemloft.net>
References: <1446565972-4269-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1446565972-4269-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Tue,  3 Nov 2015 10:52:52 -0500

> DSA ports must be members of a VLAN in order to ensure frame bridging
> between chained switch chips.
> 
> Thus tag them in addition to the CPU port when adding a VLAN, and skip
> them when deleting a VLAN and reporting VLAN members.
> 
> Also use the UNMODIFIED egress policy, so that frames egress on these
> ports as they ingress, tagged or untagged.
> 
> Fixes: 0d3b33e60206 ("net: dsa: mv88e6xxx: add VLAN Load support")
> Reported-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
