From: Joe Perches <joe@perches.com>
Subject: [PATCH next 00/16] treewide: Use static const char * const where
	possible
Date: Mon, 13 Sep 2010 21:23:46 -0700
Message-ID: <cover.1284435709.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, alsa-devel@alsa-project.org,
	linux-usb@vger.kernel.org, linux-ia64@vger.kernel.org,
	linux-scsi@vger.kernel.org, kvm@vger.kernel.org,
	microblaze-uclinux@itee.uq.edu.au, linux-alpha@vger.kernel.org,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	dri-devel@lists.freedesktop.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org, linux-watchdog@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Sender: devel-bounces@linuxdriverproject.org
Errors-To: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Convert the uses that should be const of
	char *foo[] = {"bar", "baz"};
to
	const char * const foo[] = {"bar", "baz"};
or
	static const char * const foo[] = {"bar", "baz"};

Joe Perches (16):
  arch/alpha: Use static const char * const where possible
  arch/ia64: Use static const char * const where possible
  arch/microblaze: Use static const char * const where possible
  arch/x86: Use static const char * const where possible
  drivers/gpu: Use static const char * const where possible
  drivers/isdn: Use static const char * const where possible
  drivers/net: Use static const char * const where possible
  drivers/net/pcmcia: Use static const char * const where possible
  drivers/net/wireless: Use static const char * const where possible
  drivers/scsi: Use static const char * const where possible
  drivers/staging: Use static const char * const where possible
  drivers/usb: Use static const char * const where possible
  drivers/watchdog: Use static const char * const where possible
  fs: Use static const char * const where possible
  net/irda: Use static const char * const where possible
  sound: Use static const char * const where possible

 arch/alpha/kernel/err_ev6.c                  |   12 +++++---
 arch/alpha/kernel/err_marvel.c               |   33 ++++++++++++------------
 arch/alpha/kernel/err_titan.c                |   35 ++++++++++++++-----------
 arch/alpha/kernel/osf_sys.c                  |    4 +-
 arch/ia64/kernel/palinfo.c                   |    2 +-
 arch/microblaze/kernel/heartbeat.c           |   10 +++---
 arch/microblaze/kernel/timer.c               |   12 ++++----
 arch/x86/kernel/smpboot.c                    |    2 +-
 arch/x86/kvm/mmu.c                           |    2 +-
 drivers/gpu/drm/ttm/ttm_page_alloc.c         |    4 ++-
 drivers/isdn/pcbit/edss1.c                   |    2 +-
 drivers/isdn/pcbit/edss1.h                   |    2 +-
 drivers/net/3c515.c                          |    4 ++-
 drivers/net/eth16i.c                         |    4 ++-
 drivers/net/pcmcia/3c589_cs.c                |    2 +-
 drivers/net/wireless/rt2x00/rt2x00debug.c    |    2 +-
 drivers/scsi/bfa/rport.c                     |    4 ++-
 drivers/scsi/pcmcia/nsp_debug.c              |    2 +-
 drivers/scsi/qla2xxx/qla_nx.c                |    4 +-
 drivers/scsi/qla4xxx/ql4_nx.c                |    2 +-
 drivers/staging/ath6kl/os/linux/ar6000_drv.c |   14 +++++-----
 drivers/staging/bcm/Debug.c                  |    5 ++-
 drivers/usb/host/oxu210hp-hcd.c              |    2 +-
 drivers/watchdog/machzwd.c                   |    2 +-
 fs/binfmt_flat.c                             |    4 ++-
 include/net/irda/irlan_event.h               |    2 +-
 net/irda/irlan/irlan_event.c                 |    2 +-
 sound/core/misc.c                            |    5 +---
 sound/core/pcm_native.c                      |    2 +-
 29 files changed, 99 insertions(+), 83 deletions(-)

-- 
1.7.3.rc1
