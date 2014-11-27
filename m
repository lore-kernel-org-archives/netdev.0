From: Roger Chen <roger.chen@rock-chips.com>
Subject: [PATCH v2 0/6] support GMAC driver for RK3288
Date: Thu, 27 Nov 2014 10:51:05 +0800
Message-ID: <1417056665-3606-1-git-send-email-roger.chen@rock-chips.com>
References: <1417056591-3570-1-git-send-email-roger.chen@rock-chips.com>
Cc: heiko@sntech.de, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, linux-rockchip@lists.infradead.org,
	kever.yang@rock-chips.com, eddie.cai@rock-chips.com,
	roger.chen@rock-chips.com
To: peppe.cavallaro@st.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1417056591-3570-1-git-send-email-roger.chen@rock-chips.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Roger Chen (6):
  patch1: add driver for Rockchip RK3288 SoCs integrated GMAC
  patch2: define clock ID used for GMAC
  patch3: modify CRU config for Rockchip RK3288 SoCs integrated GMAC
  patch4: dts: rockchip: add gmac info for rk3288
  patch5: dts: rockchip: enable gmac on RK3288 evb board
  patch6: add document for Rockchip RK3288 GMAC

Tested on rk3288 evb board:
Execute the following command to enable ethernet,
set local IP and ping a remote host.

busybox ifconfig eth0 up
busybox ifconfig eth0 192.168.1.111
ping 192.168.1.1

-- 
1.7.9.5
