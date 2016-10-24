From: Alexandre TORGUE <alexandre.torgue-qxv4g6HH51o@public.gmane.org>
Subject: [PATCH v2 0/3] STM32F429: Add Ethernet fixes
Date: Mon, 24 Oct 2016 10:40:03 +0200
Message-ID: <1477298406-22805-1-git-send-email-alexandre.torgue@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org>,
        <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: <peppe.cavallaro-qxv4g6HH51o@public.gmane.org>,
        Maxime Coquelin <mcoquelin.stm32-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, <arnd-r2nGTMty4D4@public.gmane.org>,
        <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This v2 to avoid build issue when only patch 1 (of first series) 
was build. 

This series adds several fixes for Ethernet for stm32f429 MCU.
First patch has already been reviewed some months ago when 
stm32 Ethernet glue has been pushed (I added in this series to keep
history). Fixes are:
 -Change DT to be compliant to stm32 ethernet glue binding
 -Add phy-handle to correctly use mdio subnode
 -Remove WoL support

changes since v1:
 -squash patch1 and patch2. 

Regards

Alex

Alexandre TORGUE (3):
  ARM: dts: stm32f429: Align Ethernet node with new bindings properties
  ARM: dts: stm32f429: Fix Ethernet node on Eval Board
  ARM: dts: stm32f429: remove Ethernet wake on Lan support

 arch/arm/boot/dts/stm32429i-eval.dts |  7 ++++---
 arch/arm/boot/dts/stm32f429.dtsi     | 10 +++++-----
 2 files changed, 9 insertions(+), 8 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
