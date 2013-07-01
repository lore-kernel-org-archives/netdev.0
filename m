From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH RFC 0/3] extend stmmac DT support.
Date: Mon,  1 Jul 2013 12:42:42 +0100
Message-ID: <1372678962-12959-1-git-send-email-srinivas.kandagatla@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Hi Peppe,

This patch series adds support to new gmac versions 3.6.10 and 3.710, these
versions of IP are integrated into ST STiH415/STiH416 SOCs.
This patchset also adds phy reset capablity to stmmac-mdio driver via DT.


Thanks,
srini

Srinivas Kandagatla (3):
  dt:net:stmmac: Allocate platform data only if its NULL.
  dt:net:stmmac: Add support to dwmac version 3.610 and 3.710
  dt:net:stmmac: Add dt specific phy reset callback support.

 Documentation/devicetree/bindings/net/stmmac.txt   |   10 ++++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   31 ++++++++++++++++++++
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   31 ++++++++++++++++++--
 3 files changed, 69 insertions(+), 3 deletions(-)

-- 
1.7.6.5
