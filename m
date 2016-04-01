From: Giuseppe Cavallaro <peppe.cavallaro@st.com>
Subject: [PATCH (net.git) 0/3] stmmac MDIO and normal descr fixes
Date: Fri, 1 Apr 2016 09:07:13 +0200
Message-ID: <1459494436-27386-1-git-send-email-peppe.cavallaro@st.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <gabriel.fernandez@linaro.org>, <afaerber@suse.de>,
	<fschaefer.oss@googlemail.com>, <dinh.linux@gmail.com>,
	<davem@davemloft.net>, <preid@electromag.com.au>,
	<rhgadsdon@gmail.com>, <linux-kernel@vger.kernel.org>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series is to fix the problems below and recently debugged
in this mailing list:

o to fix a problem for the HW where the normal descriptor
o to fix the mdio registration according to the different
  platform configurations

I am resending all the patches again: built on top of net.git repo.

Giuseppe Cavallaro (3):
  stmmac: fix TX normal DESC
  Revert "stmmac: Fix 'eth0: No PHY found' regression"
  stmmac: fix MDIO settings

 drivers/net/ethernet/stmicro/stmmac/norm_desc.c    |   16 ++--
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c  |   16 +---
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   10 +--
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   91 ++++++++++++++------
 include/linux/stmmac.h                             |    1 -
 5 files changed, 80 insertions(+), 54 deletions(-)

-- 
1.7.4.4
