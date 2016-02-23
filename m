From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: [PATCH net-next 0/4] net: dsa: pass bridge device to drivers
Date: Tue, 23 Feb 2016 11:08:26 -0500
Message-ID: <87fuwjcsud.fsf@ketchup.mtl.sfl>
References: <1455296981-27998-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
	"David S. Miller" <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1455296981-27998-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Vivien Didelot <vivien.didelot@savoirfairelinux.com> writes:

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

The dependent fix from net is now merged into net-next, which makes this
patchset apply well. I'm sending the second patchset right away.

Thanks,
-v
