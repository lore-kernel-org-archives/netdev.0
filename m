From: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>
Subject: [PATCH net-next 0/5] NetCP: Add support for version 1.5
Date: Fri, 20 Mar 2015 16:11:20 -0400
Message-ID: <1426882285-4873-1-git-send-email-m-karicheri2@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Murali Karicheri <m-karicheri2-l0cyMroinI0@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>,
	"Lad, Prabhakar" <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>,
	Christoph Jaeger <cj-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>,
	Lokesh Vutla <lokeshvutla-l0cyMroinI0@public.gmane.org>,
	Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>,
	Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>,
	Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>,
	Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>,
	Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>, <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	<devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

NetCP 1.5 is used in newer K2 SoCs from Texas Instruments
such as K2E, K2L etc. This patch series add support for Ethss
driver for this version of NetCP. While at it, fix couple of
bugs in the original driver.

One of the earlier patch "net: netcp: select davinci_mdio driver
by default" is folded onto this series.

Please review and let me know your comments.

Thanks 

CC: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
CC: Mugunthan V N <mugunthanvnm-l0cyMroinI0@public.gmane.org>
CC: "Lad, Prabhakar" <prabhakar.csengg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
CC: Grygorii Strashko <grygorii.strashko-l0cyMroinI0@public.gmane.org>
CC: Christoph Jaeger <cj-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org>
CC: Lokesh Vutla <lokeshvutla-l0cyMroinI0@public.gmane.org>
CC: Markus Pargmann <mpa-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
CC: Kumar Gala <galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
CC: Ian Campbell <ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org>
CC: Mark Rutland <mark.rutland-5wv7dgnIgG8@public.gmane.org>
CC: Pawel Moll <pawel.moll-5wv7dgnIgG8@public.gmane.org>
CC: Rob Herring <robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>

Murali Karicheri (4):
  net: netcp: fix forward port number usage for 10G ethss
  net: netcp: use separate reg region for individual ethss modules
  net: netcp: select davinci_mdio driver by default
  net: netcp: enclose macros in parentheses

WingMan Kwok (1):
  net: netcp: ethss: enhancement to support NetCP 1.5 ethss

 .../devicetree/bindings/net/keystone-netcp.txt     |   34 +-
 drivers/net/ethernet/ti/Kconfig                    |    1 +
 drivers/net/ethernet/ti/netcp.h                    |    5 +-
 drivers/net/ethernet/ti/netcp_core.c               |   23 +-
 drivers/net/ethernet/ti/netcp_ethss.c              | 1581 ++++++++++++++++----
 5 files changed, 1303 insertions(+), 341 deletions(-)

-- 
1.7.9.5

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
