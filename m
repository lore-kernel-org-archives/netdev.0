From: Srinivas KANDAGATLA <srinivas.kandagatla@st.com>
Subject: [PATCH v1 0/3] extend stmmac DT support.
Date: Tue,  2 Jul 2013 14:03:39 +0100
Message-ID: <1372770219-1643-1-git-send-email-srinivas.kandagatla@st.com>
Cc: Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	Grant Likely <grant.likely@linaro.org>,
	Rob Herring <rob.herring@calxeda.com>,
	Rob Landley <rob@landley.net>,
	devicetree-discuss@lists.ozlabs.org, linux-doc@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>
To: netdev@vger.kernel.org
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Srinivas Kandagatla <srinivas.kandagatla@st.com>

Hi Peppe,

Thankyou for the comments on RFC patches.

This patch series adds support to new gmac versions 3.6.10 and 3.710, these
versions of IP are integrated into ST STiH415/STiH416 SOCs.
This patchset also adds phy reset capablity to stmmac-mdio driver via DT.

Changes since RFC:
	- re-use existing compatible strings to select right properties.
	- clean up reset callback support so that DT is not parsed everytime.

Thanks,
srini

Srinivas Kandagatla (3):
  dt:net:stmmac: Allocate platform data only if its NULL.
  dt:net:stmmac: Add support to dwmac version 3.610 and 3.710
  dt:net:stmmac: Add dt specific phy reset callback support.

 Documentation/devicetree/bindings/net/stmmac.txt   |   10 ++++
 drivers/net/ethernet/stmicro/stmmac/stmmac_mdio.c  |   50 +++++++++++++++++++-
 .../net/ethernet/stmicro/stmmac/stmmac_platform.c  |   32 +++++++++++-
 include/linux/stmmac.h                             |    4 ++
 4 files changed, 91 insertions(+), 5 deletions(-)

-- 
1.7.6.5

