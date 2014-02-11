From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v2 0/2] dp83640: Get pin and master/slave configuration from DT
Date: Tue, 11 Feb 2014 16:29:20 +0100
Message-ID: <1392132562-23644-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, grant.likely@linaro.org,
	robh+dt@kernel.org, mark.rutland@arm.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, devicetree@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series add DT configuration to the DP83640 PHY driver and ma=
kes
the configuration of periodic output pins dynamic.

Changes since v1:
 - Add bindings documentation
 - Keep module parameters
 - Rename gpio->pin
 - Split patch into DT part and dynamic periodic output support

Stefan


Stefan S=C3=B8rensen (2):
  dp83640: Support a configurable number of periodic outputs
  dp83640: Get pin and master/slave configuration from DT

 Documentation/devicetree/bindings/net/dp83640.txt |  29 +++
 drivers/net/phy/dp83640.c                         | 205 ++++++++++++++=
+-------
 2 files changed, 175 insertions(+), 59 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dp83640.txt

--=20
1.8.5.3
