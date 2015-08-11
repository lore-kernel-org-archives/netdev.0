From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH v2 0/2] net: thunder: Add ACPI support.
Date: Mon, 10 Aug 2015 17:58:35 -0700
Message-ID: <1439254717-2875-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-mips@linux-mips.org, Robert Richter <rrichter@cavium.com>,
	Tomasz Nowicki <tomasz.nowicki@linaro.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	Mark Rutland <mark.rutland@arm.com>, rafael@kernel.org,
	David Daney <david.daney@cavium.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-acpi-owner@vger.kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Change from v1:  Drop PHY binding part, use fwnode_property* APIs.

The first patch (1/2) rearranges the existing code a little with no
functional change to get ready for the second.  The second (2/2) does
the actual work of adding support to extract the needed information
from the ACPI tables.

David Daney (1):
  net, thunder, bgx: Add support to get MAC address from ACPI.

Robert Richter (1):
  net: thunder: Factor out DT specific code in BGX

 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 134 +++++++++++++++++++---
 1 file changed, 120 insertions(+), 14 deletions(-)

-- 
1.9.1

