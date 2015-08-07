From: David Daney <ddaney.cavm@gmail.com>
Subject: [PATCH 0/2] net: thunder: Add ACPI support.
Date: Thu,  6 Aug 2015 17:33:08 -0700
Message-ID: <1438907590-29649-1-git-send-email-ddaney.cavm@gmail.com>
Cc: linux-mips@linux-mips.org, Robert Richter <rrichter@cavium.com>,
	Tomasz Nowicki <tomasz.nowicki@linaro.org>,
	Sunil Goutham <sgoutham@cavium.com>,
	linux-arm-kernel@lists.infradead.org, linux-acpi@vger.kernel.org,
	David Daney <david.daney@cavium.com>
To: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
Return-path: <linux-acpi-owner@vger.kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Daney <david.daney@cavium.com>

Hook up PHYs, and get MAC address from ACPI for the thunder driver.

The first patch (1/2) rearranges the existing code a little with no
functional change to get ready for the second.  The second (2/2) does
the actual work of adding support to extract the needed information
from the ACPI tables.

David Daney (1):
  net, thunder, bgx: Add support for ACPI binding.

Robert Richter (1):
  net: thunder: Factor out DT specific code in BGX

 drivers/net/ethernet/cavium/thunder/thunder_bgx.c | 183 ++++++++++++++++++++--
 1 file changed, 169 insertions(+), 14 deletions(-)

-- 
1.9.1

