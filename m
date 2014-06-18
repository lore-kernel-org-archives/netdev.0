From: Varka Bhadram <varkabhadram-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH net-next v4 0/3] Driver for TI CC2520
	Radio
Date: Wed, 18 Jun 2014 19:36:40 +0530
Message-ID: <1403100403-6429-1-git-send-email-varkab@cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Varka Bhadram <varkab-If5XQcfNmg0@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

This series adds the driver support for TI cc2520 radio.
also devicetree bindings for the driver.

changes since v3:
	-drop the unused varible.

changes since v2:
	- drop spi mode dt binding

changes since v1:
	- improverment in gpio setup
	- changed len pointer to len variable

changes for v1:
	- improvements in the locking mechanism in Tx and SFD ISR.
	- proper checkings for GPIO pins.
	- avoids the memory leak for priv.
	- used devm_* APIs.
	- moved the code from header file to .c file
	- removed cc2520_unregister()

Varka Bhadram (3):
  ieee802154: cc2520: adds driver for TI CC2520 radio
  ieee802154: cc2520: add driver to kernel build system
  devicetree: add device tree bindings for cc2520 driver

 .../devicetree/bindings/net/ieee802154/cc2520.txt  |   29 +
 drivers/net/ieee802154/Kconfig                     |   11 +
 drivers/net/ieee802154/Makefile                    |    1 +
 drivers/net/ieee802154/cc2520.c                    |  967 ++++++++++++++++++++
 include/linux/spi/cc2520.h                         |   26 +
 5 files changed, 1034 insertions(+)
 create mode 100644 Documentation/devicetree/bindings/net/ieee802154/cc2520.txt
 create mode 100644 drivers/net/ieee802154/cc2520.c
 create mode 100644 include/linux/spi/cc2520.h

-- 
1.7.9.5


------------------------------------------------------------------------------
HPCC Systems Open Source Big Data Platform from LexisNexis Risk Solutions
Find What Matters Most in Your Big Data with HPCC Systems
Open Source. Fast. Scalable. Simple. Ideal for Dirty Data.
Leverages Graph Analysis for Fast Processing & Easy Data Exploration
http://p.sf.net/sfu/hpccsystems
