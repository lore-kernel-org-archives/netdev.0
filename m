From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: dsa: pass bridge device to drivers
Date: Tue, 23 Feb 2016 14:53:12 -0500 (EST)
Message-ID: <20160223.145312.1892586806997582131.davem@davemloft.net>
References: <1455296981-27998-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455296981-27998-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Fri, 12 Feb 2016 12:09:37 -0500

> This patchset simplifies the DSA layer.
> 
> A switch may support multiple bridges with the same hardware VLAN. Thus a check
> such as dsa_bridge_check_vlan_range must be moved from the DSA layer to the
> concerned driver.
> 
> The first purpose of this patchset is to help moving this check to the
> mv88e6xxx driver, which is the only one affected at the moment.
> 
> To do that, pass directly the bridge net_device structure down to the DSA
> drivers, instead of calculating a bitmask of bridge members.
> 
> The second purpose is to prepare the replacement of the complex
> port_vlan_getnext approach. A second patchset is ready to follow, implementing
> port_vlan_dump and thus simplifying the DSA slave code one more time.
> 
> Note that this patchset applies on top of https://lkml.org/lkml/2016/2/5/532.

Series applied, thanks Vivien.
