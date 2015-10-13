From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: dsa: mv88e6xxx: fix hardware bridging
Date: Tue, 13 Oct 2015 04:27:07 -0700 (PDT)
Message-ID: <20151013.042707.1037079582649207903.davem@davemloft.net>
References: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel@savoirfairelinux.com, linux@roeck-us.net, andrew@lunn.ch,
	f.fainelli@gmail.com, narmstrong@baylibre.com
To: vivien.didelot@savoirfairelinux.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1444601318-20561-1-git-send-email-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Date: Sun, 11 Oct 2015 18:08:34 -0400

> DSA and its drivers currently hook the NETDEV_CHANGEUPPER net_device event in
> order to configure the VLAN map of every port.
> 
> This VLAN map is a feature of these switch chips to hardcode and restrict which
> output ports a given input port can egress frames to.
> 
> A Linux bridge is a simple untagged VLAN propagated by the bridge code itself.
> With a proper 802.1Q support, a driver does not need this hook anymore, and
> will simply program the related VLAN object.
> 
> This patchset improves the hardware bridging code in the mv88e6xxx driver with
> a strict 802.1Q mode.
> 
> Ideally, the equivalent must be done for Broadcom Starfighter 2 and Rocker,
> before completely getting rid of this hook.

Series applied, thanks Vivien.
