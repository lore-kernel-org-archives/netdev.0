From: Tushar Behera <tushar.behera@linaro.org>
Subject: [PATCH 00/14] Modify signed comparisons of unsigned variables
Date: Fri, 16 Nov 2012 12:20:32 +0530
Message-ID: <1353048646-10935-1-git-send-email-tushar.behera@linaro.org>
Cc: patches@linaro.org, Mauro Carvalho Chehab <mchehab@infradead.org>,
	Linus Walleij <linus.walleij@linaro.org>,
	Ian Campbell <ian.campbell@citrix.com>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Jack Steiner <steiner@sgi.com>, Arnd Bergmann <arnd@arndb.de>,
	Luciano Coelho <coelho@ti.com>, Jiri Kosina <jkosina@suse.cz>,
	ivtv-devel@ivtvdriver.org, linux-media@vger.kernel.org,
	xen-devel@lists.xensource.com, netdev@vger.kernel.org,
	virtualization@lists.linux-foundation.org,
	linux-atm-general@lists.sourceforge.net, linux-usb@vger.kernel.org,
	linux-input@vger.kernel.org, linux-wireless@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-input-owner@vger.kernel.org>
Sender: linux-input-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The occurrences were identified through the coccinelle script at
following location.

http://www.emn.fr/z-info/coccinelle/rules/find_unsigned.cocci

Signed checks for unsigned variables are removed if it is also checked
for upper error limit. For error checks, IS_ERR_VALUE() macros is used.

Tushar Behera (14):
  [media] ivtv: Remove redundant check on unsigned variable
  [media] meye: Remove redundant check on unsigned variable
  [media] saa7134: Remove redundant check on unsigned variable
  [media] tlg2300: Remove redundant check on unsigned variable
  [media] atmel-isi: Update error check for unsigned variables
  pinctrl: samsung: Update error check for unsigned variables
  pinctrl: SPEAr: Update error check for unsigned variables
  xen: netback: Remove redundant check on unsigned variable
  xen: events: Remove redundant check on unsigned variable
  atm: Removed redundant check on unsigned variable
  HID: hiddev: Remove redundant check on unsigned variable
  gru: Remove redundant check on unsigned variable
  misc: tsl2550: Remove redundant check on unsigned variable
  wlcore: Remove redundant check on unsigned variable

 drivers/atm/fore200e.c                        |    2 +-
 drivers/hid/usbhid/hiddev.c                   |    2 +-
 drivers/media/pci/ivtv/ivtv-ioctl.c           |    2 +-
 drivers/media/pci/meye/meye.c                 |    2 +-
 drivers/media/pci/saa7134/saa7134-video.c     |    2 +-
 drivers/media/platform/soc_camera/atmel-isi.c |    2 +-
 drivers/media/usb/tlg2300/pd-video.c          |    2 +-
 drivers/misc/sgi-gru/grukdump.c               |    2 +-
 drivers/misc/tsl2550.c                        |    4 ++--
 drivers/net/wireless/ti/wlcore/debugfs.c      |    2 +-
 drivers/net/xen-netback/netback.c             |    4 ++--
 drivers/pinctrl/pinctrl-samsung.c             |    2 +-
 drivers/pinctrl/spear/pinctrl-plgpio.c        |    2 +-
 drivers/xen/events.c                          |    2 +-
 14 files changed, 16 insertions(+), 16 deletions(-)

-- 
1.7.4.1

CC: Mauro Carvalho Chehab <mchehab@infradead.org>
CC: Linus Walleij <linus.walleij@linaro.org>
CC: Ian Campbell <ian.campbell@citrix.com>
CC: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
CC: Jeremy Fitzhardinge <jeremy@goop.org>
CC: Chas Williams <chas@cmf.nrl.navy.mil>
CC: Jack Steiner <steiner@sgi.com>
CC: Arnd Bergmann <arnd@arndb.de>
CC: Luciano Coelho <coelho@ti.com>
CC: Jiri Kosina <jkosina@suse.cz>
CC: ivtv-devel@ivtvdriver.org
CC: linux-media@vger.kernel.org
CC: xen-devel@lists.xensource.com
CC: netdev@vger.kernel.org
CC: virtualization@lists.linux-foundation.org
CC: linux-atm-general@lists.sourceforge.net
CC: linux-usb@vger.kernel.org
CC: linux-input@vger.kernel.org
CC: linux-wireless@vger.kernel.org
