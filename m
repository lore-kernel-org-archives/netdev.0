From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 0/6] arc_emac: fixes the emac issues oand cleanup emac
 drivers
Date: Fri, 11 Mar 2016 16:46:33 +0300
Message-ID: <56E2CC39.6050907@cogentembedded.com>
References: <1457693731-6966-1-git-send-email-wxt@rock-chips.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rockchip@lists.infradead.org, keescook@google.com,
	leozwang@google.com, devicetree@vger.kernel.org,
	Michael Turquette <mturquette@baylibre.com>,
	Alexander Kochetkov <al.kochet@gmail.com>,
	Russell King <linux@arm.linux.org.uk>,
	Stephen Boyd <sboyd@codeaurora.org>, netdev@vger.kernel.org,
	Kumar Gala <galak@codeaurora.org>,
	linux-kernel@vger.kernel.org,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	zhengxing <zhengxing@rock-chips.com>,
	Jiri Kosina <trivial@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>, linux-clk@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Caesar Wang <wxt@rock-chips.com>, Heiko Stuebner <heiko@sntech.de>,
	"David S. Miller" <davem@davemloft.net>,
	Rob Herring <robh+dt@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:36259 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753111AbcCKNqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Mar 2016 08:46:39 -0500
Received: by mail-lb0-f177.google.com with SMTP id x1so156210681lbj.3
        for <netdev@vger.kernel.org>; Fri, 11 Mar 2016 05:46:38 -0800 (PST)
In-Reply-To: <1457693731-6966-1-git-send-email-wxt@rock-chips.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 3/11/2016 1:55 PM, Caesar Wang wrote:

> This series patches are based on kernel 4.5-rc7+ version.
> Linux version 4.5.0-rc7-next-20160310+ (wxt@nb) (...) #23 SMP Fri Mar 11 15:55:53

[...]

> 1) This series has 6 patches: (1--->6)
> net: arc_emac: make the rockchip emac document more compatible
> net: arc_emac: add phy-reset-* are optional for device tree

    I'm not seeing these patches on netdev...

> net: arc_emac: support the phy reset for emac driver
> net: arc: trivial: cleanup the emac driver
> clk: rockchip: rk3036: fix and add node id for emac clock
> ARM: dts: rockchip: add support emac for RK3036
>
> 2) This series patches have the following decriptions:

    Descriptions.

> Hi Rob, David:
> PATCH[1/6-2/6]: ====>
> net: arc_emac: make the rockchip emac document more compatible
> net: arc_emac: add phy-reset-* are optional for device tree
>
> The patches change the rockchip emac document for more compatible and
> Add the phy-reset-* property for document.
>
> This patch adds the following property for arc_emac.
>
> phy-reset-* include the following:
> 1) phy-reset-gpios:
> The phy-reset-gpios is an optional property for arc emac device tree boot.
> Change the binding document to match the driver code.
>
> 2) phy-reset-duration:
> Different boards may require different phy reset duration. Add property
> phy-reset-duration for device tree probe, so that the boards that need
> a longer reset duration can specify it in their device tree.
>
> 3) phy-reset-active-high:
> We need that for a custom hardware that needs the reverse reset sequence.

    Why not infer this from the "phy-reset-gpios" prop?

MBR, Sergei
