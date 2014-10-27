From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/11] treewide: mask then shift defects and style updates
Date: Sun, 26 Oct 2014 22:24:56 -0700
Message-ID: <cover.1414387334.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, linux-wireless@vger.kernel.org,
 linux-input@vger.kernel.org
To: linux-kernel@vger.kernel.org, linux-nvme@lists.infradead.org,
 dri-devel@lists.freedesktop.org, ivtv-devel@ivtvdriver.org,
 linux-media@vger.kernel.org, patches@opensource.wolfsonmicro.com,
 netdev@vger.kernel.org, linux-usb@vger.kernel.org,
 linux-parisc@vger.kernel.org
Return-path: <dri-devel-bounces@lists.freedesktop.org>
List-Unsubscribe: <http://lists.freedesktop.org/mailman/options/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=unsubscribe>
List-Archive: <http://lists.freedesktop.org/archives/dri-devel>
List-Post: <mailto:dri-devel@lists.freedesktop.org>
List-Help: <mailto:dri-devel-request@lists.freedesktop.org?subject=help>
List-Subscribe: <http://lists.freedesktop.org/mailman/listinfo/dri-devel>,
 <mailto:dri-devel-request@lists.freedesktop.org?subject=subscribe>
Errors-To: dri-devel-bounces@lists.freedesktop.org
Sender: "dri-devel" <dri-devel-bounces@lists.freedesktop.org>
List-Id: netdev.vger.kernel.org

logical mask has lower precedence than shift but should be
done before the shift so parentheses are generally required.

And when masking with a fixed value after a shift, normal kernel
style has the shift on the left, then the shift on the right so
convert a few non-conforming uses.

Joe Perches (11):
  block: nvme-scsi: Fix probable mask then right shift defects
  radeon: evergreen: Fix probable mask then right shift defects
  aiptek: Fix probable mask then right shift defects
  dvb-net: Fix probable mask then right shift defects
  cx25840/cx18: Use standard ordering of mask and shift
  wm8350-core: Fix probable mask then right shift defect
  iwlwifi: dvm: Fix probable mask then right shift defect
  ssb: driver_chip_comon_pmu: Fix probable mask then right shift defect
  tty: ipwireless: Fix probable mask then right shift defects
  hwa-hc: Fix probable mask then right shift defect
  sound: ad1889: Fix probable mask then right shift defects

 drivers/block/nvme-scsi.c                | 12 ++++++------
 drivers/gpu/drm/radeon/evergreen.c       |  3 ++-
 drivers/input/tablet/aiptek.c            |  6 +++---
 drivers/media/dvb-core/dvb_net.c         |  4 +++-
 drivers/media/i2c/cx25840/cx25840-core.c | 12 ++++++------
 drivers/media/pci/cx18/cx18-av-core.c    | 16 ++++++++--------
 drivers/mfd/wm8350-core.c                |  2 +-
 drivers/net/wireless/iwlwifi/dvm/lib.c   |  4 ++--
 drivers/ssb/driver_chipcommon_pmu.c      |  4 ++--
 drivers/tty/ipwireless/hardware.c        | 12 ++++++------
 drivers/usb/host/hwa-hc.c                |  2 +-
 sound/pci/ad1889.c                       |  8 ++++----
 12 files changed, 44 insertions(+), 41 deletions(-)

-- 
2.1.2
