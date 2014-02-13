From: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
Subject: [PATCH v3 0/3] dp83640: Get pin and master/slave configuration from DT
Date: Thu, 13 Feb 2014 15:35:26 +0100
Message-ID: <1392302129-24947-5-git-send-email-stefan.sorensen@spectralink.com>
References: <1392302129-24947-1-git-send-email-stefan.sorensen@spectralink.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Stefan=20S=C3=B8rensen?=
	<stefan.sorensen@spectralink.com>
To: richardcochran@gmail.com, grant.likely@linaro.org,
	robh+dt@kernel.org, mark.rutland@arm.com,
	devicetree@vger.kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1392302129-24947-1-git-send-email-stefan.sorensen@spectralink.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch series add DT configuration to the DP83640 PHY driver and ma=
kes
the configuration of periodic output pins dynamic.

Changes since v2:
 - Add patch to properly configure perout triggers 0+1
 - Keep extts and perout numbers separate
 - Shorten pr_err lines

Changes since v1:
 - Add bindings documentation
 - Keep module parameters
 - Rename gpio->pin
 - Split patch into DT part and dynamic periodic output support

Stefan S=C3=B8rensen (3):
  net:phy:dp83640: Program pulsewidth2 values of perout triggers 0 and =
1
  net:phy:dp83640: Support a configurable number of periodic outputs
  net:phy:dp83640: Get pin and master/slave configuration from DT

 Documentation/devicetree/bindings/net/dp83640.txt |  29 ++++
 drivers/net/phy/dp83640.c                         | 199 ++++++++++++++=
+-------
 2 files changed, 170 insertions(+), 58 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/dp83640.txt

--=20
1.8.5.3
