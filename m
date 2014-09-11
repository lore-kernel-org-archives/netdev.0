From: Kweh Hock Leong <hock.leong.kweh@intel.com>
Subject: [PATCH v2 0/4] net: stmmac: Enable Intel Quark SoC X1000 Ethernet support
Date: Thu, 11 Sep 2014 16:38:36 +0800
Message-ID: <cover.1410416223.git.hock.leong.kweh@intel.com>
Cc: Vince Bridgers <vbridgers2013@gmail.com>,
	Srinivas Kandagatla <srinivas.kandagatla@st.com>,
	Chen-Yu Tsai <wens@csie.org>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Ong Boon Leong <boon.leong.ong@intel.com>,
	Kweh Hock Leong <hock.leong.kweh@intel.com>
To: "David S. Miller" <davem@davemloft.net>,
	Giuseppe Cavallaro <peppe.cavallaro@st.com>,
	rayagond@vayavyalabs.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Kweh, Hock Leong" <hock.leong.kweh@intel.com>

Hi,

Intel Quark X1000 SoC has 2 Ethernet controllers integrated on chip and they are
PCI devices. We adopted the stmmac_pci driver and added on code to support Intel
Quark SoC X1000 by creating the patchset below. The patchset has been built and
tested on Galileo board and found to be working as expected.

We believe that the changes are transparent to other non Intel Quark platform. 
Please help to review the code change and feedback if there is any concern.

Thank you very much.

---
changelog v2:
[PATCH 1/4]
* fix indentation to align with the 1st column of openning parenthesis
* replace the static variable instance_id by using pci bus & devfn number
[PATCH 2/4]
* replace the static variable instance_id by using pci bus & devfn number
[PATCH 3/4]
* replace the static variable instance_id by using pci bus & devfn number

Kweh, Hock Leong (4):
  net: stmmac: enhance to support multiple device instances
  net: stmmac: better code manageability with platform data struct
  net: stmmac: add support for Intel Quark X1000
  net: stmmac: add MSI support for Intel Quark X1000

 drivers/net/ethernet/stmicro/stmmac/stmmac_pci.c |  194 +++++++++++++++++++---
 1 file changed, 171 insertions(+), 23 deletions(-)

-- 
1.7.9.5
