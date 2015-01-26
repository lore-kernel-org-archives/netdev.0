From: Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [PATCH v2 0/2] Add ACPI support for NXP PN544
Date: Mon, 26 Jan 2015 13:13:35 +0200
Message-ID: <1422270817-10950-1-git-send-email-robert.dolca@intel.com>
Cc: linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Berg Johannes <johannes.berg-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
	Clement Perrochaud <clement.perrochaud-3arQi8VN3Tc@public.gmane.org>,
	Robert Dolca <robert.dolca-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
To: linux-nfc-hn68Rpc1hR1g9hUCZPvPmw@public.gmane.org,
	Lauro Ramos Venancio <lauro.venancio-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Aloisio Almeida Jr <aloisio.almeida-430g2QfJUUCGglJvpFV4uA@public.gmane.org>,
	Samuel Ortiz <sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch set introduces ACPI support for PN544.

gpio_set_value was replaced with gpio_set_value_cansleep in order
to allow GPIO access that may sleep. This is particularelly useful
when GPIO is accessed using busses like I2C, SPI, USB

Changes since v1:
	- Added cover letter
	- Removed debug define and Kconfig include
	- Minor fixes to patch subjects

Links to v1:
	- http://lkml.iu.edu/hypermail/linux/kernel/1501.1/00943.html
	- http://lkml.iu.edu/hypermail/linux/kernel/1501.1/00944.html

Robert Dolca (2):
  NFC: PN544: GPIO access that may sleep
  NFC: Add ACPI support for NXP PN544

 drivers/nfc/pn544/i2c.c | 137 +++++++++++++++++++++++++++++++++++++++++++-----
 1 file changed, 124 insertions(+), 13 deletions(-)

-- 
1.9.1

--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
