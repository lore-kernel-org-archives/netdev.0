From: Heikki Krogerus <heikki.krogerus@linux.intel.com>
Subject: [PATCH 0/5] rfkill-gpio: ACPI support
Date: Wed, 16 Oct 2013 13:53:38 +0300
Message-ID: <1381920823-15403-1-git-send-email-heikki.krogerus@linux.intel.com>
Cc: Johannes Berg <johannes@sipsolutions.net>,
	Rhyland Klein <rklein@nvidia.com>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	linux-acpi@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-acpi-owner@vger.kernel.org>
Sender: linux-acpi-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The first patches prepare the driver for the support. The last patch
can then add the support quite easily. With these patches, adding DT
support later will be quite straight forward if someone needs it.


Heikki Krogerus (5):
  net: rfkill: gpio: convert to resource managed allocation
  net: rfkill: gpio: clean up clock handling
  net: rfkill: gpio: spinlock-safe GPIO access
  net: rfkill: gpio: prepare for DT and ACPI support
  net: rfkill: gpio: add ACPI support

 net/rfkill/Kconfig       |   2 +-
 net/rfkill/rfkill-gpio.c | 211 ++++++++++++++++++++++-------------------------
 2 files changed, 99 insertions(+), 114 deletions(-)

-- 
1.8.4.rc3

