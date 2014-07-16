From: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
Subject: [PATCH v2 0/2] net: davinci_mdio: reuse for keystone2 arch
Date: Wed, 16 Jul 2014 15:13:01 +0300
Message-ID: <1405512783-20307-1-git-send-email-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>, Sekhar Nori <nsekhar-l0cyMroinI0@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	<linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org>,
	<mugunthanvnm-l0cyMroinI0@public.gmane.org>, Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	<santosh.shilimkar-l0cyMroinI0@public.gmane.org>, <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

The similar MDIO HW blocks is used by keystone 2 SoCs as
in Davinci SoCs:
- one in Gigabit Ethernet (GbE) Switch Subsystem
  See http://www.ti.com/lit/ug/sprugv9d/sprugv9d.pdf
- one in 10 Gigabit Ethernet Subsystem
  See http://www.ti.com/lit/ug/spruhj5/spruhj5.pdf

Hence, reuse Davinci MDIO driver for Keystone 2 and
enable TI networking for Keystone 2 devices.

Also, as part of this series, enable PHY's creation from DT, because
Keystone 2 supports DT boot mode only.

Changes in v2:
- review comments applied. 
  Keystone 2 compatibility string changed to "ti,keystone_mdio".

Grygorii Strashko (2):
  net: davinci_mdio: reuse for keystone2 arch
  net: davinci_mdio: allow to create phys from dt

 .../devicetree/bindings/net/davinci-mdio.txt       |    8 ++++----
 drivers/net/ethernet/ti/Kconfig                    |    4 ++--
 drivers/net/ethernet/ti/davinci_mdio.c             |   21 ++++++++++++++++++--
 3 files changed, 25 insertions(+), 8 deletions(-)

-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
