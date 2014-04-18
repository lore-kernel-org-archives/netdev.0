From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH v2 0/4] introduce devm_mdiobus_alloc/free and clean up davinci mdio
Date: Fri, 18 Apr 2014 20:24:53 +0300
Message-ID: <1397841897-9170-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Randy Dunlap <rdunlap@infradead.org>,
	Jonathan Cameron <jic23@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	<prabhakar.csengg@gmail.com>, <santosh.shilimkar@ti.com>,
	Sekhar Nori <nsekhar@ti.com>, <linux-doc@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<davinci-linux-open-source@linux.davincidsp.com>,
	<sergei.shtylyov@cogentembedded.com>,
	Grygorii Strashko <grygorii.strashko@ti.com>
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Introduce a resource managed devm_mdiobus_alloc()/devm_mdiobus_free()
to automatically clean up MDIO bus alocations made by MDIO drivers,
thus leading to simplified MDIO drivers code.

Clean up Davinci MDIO driver and use new devm API.

Changes in v2:
- minor comments taken into account
- additional patches added for cleaning up Davinci MDIO driver

Cc: Florian Fainelli <f.fainelli@gmail.com>

Grygorii Strashko (4):
  mdio_bus: implement devm_mdiobus_alloc/devm_mdiobus_free
  net: davinci_mdio: use devm_* api
  net: davinci_mdio: drop pinctrl_pm_select_default_state from probe
  net: davinci_mdio: simplify IO memory mapping

 Documentation/driver-model/devres.txt  |    4 ++
 drivers/net/ethernet/ti/davinci_mdio.c |   48 ++++------------------
 drivers/net/phy/mdio_bus.c             |   68 ++++++++++++++++++++++++++++++++
 include/linux/phy.h                    |    2 +
 4 files changed, 82 insertions(+), 40 deletions(-)

-- 
1.7.9.5

