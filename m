From: clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org
Subject: [PATCH v2 0/3] NFC: nxp-nci: Add support for NXP-NCI NFC controllers
Date: Mon,  9 Mar 2015 11:12:02 +0100
Message-ID: <1425895925-20593-1-git-send-email-clement.perrochaud@effinnov.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Cl=C3=A9ment=20Perrochaud?=
	<clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org>, sunil.jogi-3arQi8VN3Tc@public.gmane.org,
	jerome.pele-3arQi8VN3Tc@public.gmane.org, Charles.Gorand-Effinnov-3arQi8VN3Tc@public.gmane.org,
	lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org, aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org,
	sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org, robh+dt-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, pawel.moll-5wv7dgnIgG8@public.gmane.org,
	mark.rutland-5wv7dgnIgG8@public.gmane.org, ijc+devicetree-KcIKpvwj1kUDXYZnReoRVg@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, grant.likely-QSEj5FYQhm4dnm+yROfE0A@public.gmane.org,
	clement.perrochaud-3arQi8VN3Tc@public.gmane.org, lefrique-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	christophe.ricard-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, cuissard-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	bzhao-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, hirent-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org, akarwar-eYqpPyKDWXRBDgjK7y7TUQ@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	anda-maria.nicolae-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org
To: linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

=46rom: Cl=C3=A9ment Perrochaud <clement.perrochaud-BPEPtVrvniRWk0Htik3J/w@public.gmane.org>

This patch brings support for the NXP-NCI NFC controllers family.

It has been successfully tested on the following SoC boards:
 - BeagleBone
 - BeagleBone Black
 - Raspberry Pi B
 - Raspberry Pi B+

The submission is broken into three patches:
 - The first one adds firmware download support to NCI ;
 - The second one adds the NXP-NCI driver's core ;
 - The third one adds I2C support to the driver.

It is based on fa00e8fed457841cb24219dbe3cfba7d56de6317 (NFC: nci: Move=
 NFCEE
discovery logic) from the nfc-next master branch.

Cl=C3=A9ment Perrochaud (3):
  NFC: nci: Add firmware download support
  NFC: nxp-nci: Add support for NXP NCI chips
  NFC: nxp-nci_i2c: Add I2C support to NXP NCI driver

 .../devicetree/bindings/net/nfc/nxp-nci.txt        |  35 ++
 MAINTAINERS                                        |   7 +
 drivers/nfc/Kconfig                                |   1 +
 drivers/nfc/Makefile                               |   1 +
 drivers/nfc/nxp-nci/Kconfig                        |  25 ++
 drivers/nfc/nxp-nci/Makefile                       |  11 +
 drivers/nfc/nxp-nci/core.c                         | 186 +++++++++
 drivers/nfc/nxp-nci/firmware.c                     | 324 +++++++++++++=
+++
 drivers/nfc/nxp-nci/i2c.c                          | 415 +++++++++++++=
++++++++
 drivers/nfc/nxp-nci/nxp-nci.h                      |  89 +++++
 include/linux/platform_data/nxp-nci.h              |  27 ++
 include/net/nfc/nci_core.h                         |   1 +
 net/nfc/nci/core.c                                 |  11 +
 13 files changed, 1133 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/nfc/nxp-nci.t=
xt
 create mode 100644 drivers/nfc/nxp-nci/Kconfig
 create mode 100644 drivers/nfc/nxp-nci/Makefile
 create mode 100644 drivers/nfc/nxp-nci/core.c
 create mode 100644 drivers/nfc/nxp-nci/firmware.c
 create mode 100644 drivers/nfc/nxp-nci/i2c.c
 create mode 100644 drivers/nfc/nxp-nci/nxp-nci.h
 create mode 100644 include/linux/platform_data/nxp-nci.h

--=20
Cl=C3=A9ment Perrochaud

Eff'Innov Technologies
Caen, Aix-En-Provence, Grenoble

Eff'Innov Technologies
Campus EffiScience
2, Esplanade Anton Philips
14460 Colombelles, FRANCE

http://www.effinnov.com

--
To unsubscribe from this list: send the line "unsubscribe linux-wireles=
s" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
