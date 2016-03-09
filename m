From: Hau <hau@realtek.com>
Subject: RE: [PATCH net] r8169:Remove unnecessary phy reset for pcie nic when setting link spped.
Date: Wed, 9 Mar 2016 16:48:41 +0000
Message-ID: <80377ECBC5453840BA8C7155328B53770137C08D@RTITMBSV03.realtek.com.tw>
References: <1457427065-3699-1-git-send-email-hau@realtek.com>
 <20160308234855.GA6182@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	nic_swsd <nic_swsd@realtek.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160308234855.GA6182@electric-eye.fr.zoreil.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

[...] 
> Can you clarify:
> - actually this patch does not care about the link at all. So when there's
>   link no phy reset is needed either, right ?
> - does "this" in "to do this" means that
>   1. phy reset prevents phy from auto speed down
>   2. avoiding phy reset prevents phy from auto speed down
>   I would expect 1. from the rtl_wol_pll_power_down + rtl_speed_down +
>   rtl8169_set_speed combo (i.e. we want the driver to allow auto speed
> down)
>   but it's a bit ambiguous.

Unless pcie nic has bug, pcie nic does not need to reset phy to let phy link on.

There is a counter for phy speed down. If phy is in link down state, this counter will start to count down. When it count to 0, phy will speed down. Reset phy will reset this counter and prevent phy from speed down.

 ------Please consider the environment before printing this e-mail.
