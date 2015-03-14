From: Alexandru M Stan <amstan@chromium.org>
Subject: [PATCH 0/1] ARM: dts: rockchip: disable gmac by default in rk3288.dtsi
Date: Fri, 13 Mar 2015 17:55:31 -0700
Message-ID: <1426294532-32078-1-git-send-email-amstan@chromium.org>
Cc: dianders@chromium.org, peppe.cavallaro@st.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linux-rockchip@lists.infradead.org, kever.yang@rock-chips.com,
	eddie.cai@rock-chips.com, Alexandru M Stan <amstan@chromium.org>,
	Russell King <linux@arm.linux.org.uk>,
	devicetree@vger.kernel.org, Kumar Gala <galak@codeaurora.org>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Rob Herring <robh+dt@kernel.org>,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	linux-arm-kernel@lists.infradead.org
To: heiko@sntech.de, roger.chen@rock-chips.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The way it is right now, each board using rk3288.dtsi has to disable
it or else (given CONFIG_DWMAC_RK is set) it will try loading the driver
and looking for phy's even though none are connected.

The status should be "disabled".

PS: I'm ok with "the big relicensing"
(http://www.spinics.net/lists/arm-kernel/msg403629.html) to GPLv2/X11.


Alexandru M Stan (1):
  ARM: dts: rockchip: disable gmac by default in rk3288.dtsi

 arch/arm/boot/dts/rk3288.dtsi | 1 +
 1 file changed, 1 insertion(+)

-- 
2.2.0.rc0.207.ga3a616c
