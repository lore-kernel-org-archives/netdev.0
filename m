From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: mv88e6xxx: do not leave reserved VLANs
Date: Sat, 13 Feb 2016 06:08:44 -0500 (EST)
Message-ID: <20160213.060844.528410343007511546.davem@davemloft.net>
References: <1454699234-6157-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, andrew@lunn.ch,
	kevin.smith@elecsyscorp.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1454699234-6157-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri,  5 Feb 2016 14:07:14 -0500

> BRIDGE_VLAN_FILTERING automatically adds a newly bridged port to the
> VLAN with the bridge's default_pvid.
> 
> The mv88e6xxx driver currently reserves VLANs 4000+ for unbridged ports
> isolation. When a port joins a bridge, it leaves its reserved VLAN. When
> a port leaves a bridge, it joins again its reserved VLAN.
> 
> But if the VLAN filtering is disabled, or if this hardware VLAN is
> already in use, the bridged port ends up with no default VLAN, and the
> communication with the CPU is thus broken.
> 
> To fix this, make a port join its reserved VLAN once on setup, never
> leave it, and restore its PVID after another one was eventually used.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>

Applied.
