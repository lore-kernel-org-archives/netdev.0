From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/3] net: dsa: mv88e6xxx: fix hardware cross-chip
 bridging
Date: Sat, 16 Apr 2016 19:07:29 -0400 (EDT)
Message-ID: <20160416.190729.1734034862162629026.davem@davemloft.net>
References: <1460659329-11473-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, f.fainelli@gmail.com, andrew@lunn.ch
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1460659329-11473-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Thu, 14 Apr 2016 14:42:06 -0400

> In order to accelerate cross-chip switching of frames with the hardware,
> the DSA Tag ports, used to interconnect switch devices, must learn SA
> and DA addresses, and share the same FDB with the user ports.
> 
> The two first patches restore address learning on DSA links. This fixes
> hardware cross-chip bridging in a VLAN filtering enabled system, which
> implements a bridge group as a 802.1Q VLAN and thus share an isolated
> address database between DSA and user ports.
> 
> The third patch changes the distinct default databases used for each
> port, to the same address database. This fixes the hardware cross-chip
> bridging in a VLAN filtering disabled system, where a bridge group gets
> implemented only as a port-based VLAN.

Series applied, thanks.
