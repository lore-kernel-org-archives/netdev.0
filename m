From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 0/4] wimax: Kbuild / rfkill-build / PM fixes (v3)
Date: Wed,  7 Jan 2009 11:22:18 -0800
Message-ID: <cover.1231355768.git.inaky@linux.intel.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>, wimax@linuxwimax.org,
	greg@kroah.com, LKML <linux-kernel@vger.kernel.org>,
	linux-wimax@intel.com, linux-next@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

These four patches fix build issues reported by Randy Dunlap on the
linux-next tree for Jan 6 and Jan 7:

http://lkml.org/lkml/2009/1/6/340
http://lkml.org/lkml/2009/1/7/360

The issue fixed by patch #3 wasn't reported on the emails but was
uncovered while discussing the fixes.

This applies to the wimax tree kept in gregkh's repository:

http://kernel.org/pub/linux/kernel/people/gregkh/gregkh-2.6/gregkh-04-usb/

Changes in v3

- Add patch #4, wrapping access to power-saving members of the struct
  usb_device in #ifdef CONFIG_PM. 

Changes in v2

- fixed silly one-char typo #ifndef CONFIG_BUG vs #ifdef CONFIG_BUG
  reported by Ilpo Järvinen 

Inaky Perez-Gonzalez (4):
  wimax: fix '#ifndef CONFIG_BUG' layout to avoid warning
  wimax: fix kconfig interactions with rfkill and input layers
  wimax: testing for rfkill support should also test for
    CONFIG_RFKILL_MODULE
  i2400m/usb: wrap USB power saving in #ifdef CONFIG_PM

 drivers/net/wimax/i2400m/usb.c |    6 ++++++
 net/wimax/Kconfig              |   14 ++++++++++++++
 net/wimax/id-table.c           |    8 +++++---
 net/wimax/op-rfkill.c          |    2 +-
 4 files changed, 26 insertions(+), 4 deletions(-)
