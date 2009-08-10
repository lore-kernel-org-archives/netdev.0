From: Dmitry Eremin-Solenikov <dbaryshkov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [RFC 0/2] Software implementation of IEEE
	802.15.4
Date: Mon, 10 Aug 2009 18:16:38 +0400
Message-ID: <1249913800-10176-1-git-send-email-dbaryshkov@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
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


Hi,

In this (small) patchset we'd like to present the grounds of our software
IEEE 802.15.4 MAC implementation. Especially this patchset contains only
packet dissection and data path (in generic parts) and virtual loopback
driver (as an example user).

Please review.

Dmitry Eremin-Solenikov (2):
      mac802154: add a software MAC 802.15.4 implementation
      ieee802154: add virtual loopback driver

 MAINTAINERS                 |    1 +
 drivers/ieee802154/Kconfig  |   13 +
 drivers/ieee802154/Makefile |    1 +
 drivers/ieee802154/fakelb.c |  255 ++++++++++++
 include/linux/mac802154.h   |   35 ++
 include/net/mac802154.h     |  106 +++++
 net/Kconfig                 |    1 +
 net/Makefile                |    1 +
 net/mac802154/Kconfig       |   17 +
 net/mac802154/Makefile      |    4 +
 net/mac802154/dev.c         |  924 +++++++++++++++++++++++++++++++++++++++++++
 net/mac802154/mac802154.h   |   85 ++++
 net/mac802154/mac_cmd.c     |   99 +++++
 net/mac802154/mdev.c        |  295 ++++++++++++++
 net/mac802154/mib.h         |   32 ++
 net/mac802154/rx.c          |   98 +++++
 16 files changed, 1967 insertions(+), 0 deletions(-)
 create mode 100644 drivers/ieee802154/fakelb.c
 create mode 100644 include/linux/mac802154.h
 create mode 100644 include/net/mac802154.h
 create mode 100644 net/mac802154/Kconfig
 create mode 100644 net/mac802154/Makefile
 create mode 100644 net/mac802154/dev.c
 create mode 100644 net/mac802154/mac802154.h
 create mode 100644 net/mac802154/mac_cmd.c
 create mode 100644 net/mac802154/mdev.c
 create mode 100644 net/mac802154/mib.h
 create mode 100644 net/mac802154/rx.c



------------------------------------------------------------------------------
Let Crystal Reports handle the reporting - Free Crystal Reports 2008 30-Day 
trial. Simplify your report design, integration and deployment - and focus on 
what you do best, core application coding. Discover what's new with 
Crystal Reports now.  http://p.sf.net/sfu/bobj-july
