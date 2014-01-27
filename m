From: Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 0/3] OpenCores 10/100 MAC fixes for gigabit environment
Date: Mon, 27 Jan 2014 07:59:24 +0400
Message-ID: <1390795167-6677-1-git-send-email-jcmvbkbc@gmail.com>
Cc: Chris Zankel <chris-YvXeqwSYzG2sTnJN9+BGXg@public.gmane.org>, Marc Gauthier <marc-vna1KIf7WgpBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Grant Likely <grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org>,
	Rob Herring <rob.herring-bsGFqQB8/DxBDgjK7y7TUQ@public.gmane.org>,
	Max Filippov <jcmvbkbc-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: linux-xtensa-PjhNF2WwrV/0Sa2dR60CXw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hello David, Grant, Rob, Chris and everybody,

this series improves ethoc behavior in gigabit environment:
- first patch disables gigabit advertisement in the attached PHY making
  possible to use gigabit link without any additional setup;
- second patch adds support to set up MII management bus frequency, adding
  new fields to platform data and to OF bindings;
- third patch documents existing and newly added OF bindings.

These changes allow to use KC-705 board with 50MHz xtensa core and OpenCores
10/100 Mbps MAC connected to gigabit network without any additional setup.

Max Filippov (3):
  net: ethoc: don't advertise gigabit speed on attached PHY
  net: ethoc: set up MII management bus clock
  net: ethoc: document OF bindings

 .../devicetree/bindings/net/opencores-ethoc.txt    | 25 +++++++++++++++++++
 drivers/net/ethernet/ethoc.c                       | 29 ++++++++++++++++++++--
 include/net/ethoc.h                                |  2 ++
 3 files changed, 54 insertions(+), 2 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/opencores-ethoc.txt

-- 
1.8.1.4

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
