From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/10] Non-printk continuation line fixes
Date: Mon,  1 Feb 2010 23:22:06 -0800
Message-ID: <cover.1265095093.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-fbdev@vger.kernel.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	linux-ia64@vger.kernel.org, kvm@vger.kernel.org,
	David Airlie <airlied@linux.ie>, alsa-devel@alsa-project.org,
	Jaroslav Kysela <perex@perex.cz>, Grant Likely <grant.likely@secretlab.ca>,
	linux-ide@vger.kernel.org, devel@driverdev.osuosl.org,
	David Brownell <dbrownell@users.sourceforge.net>,
	linux-scsi@vger.kernel.org, lm-sensors@lm-sensors.org,
	Takashi Iwai <tiwai@suse.de>, Scott Fang <ScottFang@viatech.com.cn>,
	Avi Kivity <avi@redhat.com>, dri-devel@lists.sourceforge.net,
	Jeff Garzik <jgarzik@pobox.com>, Xiantao Zhang <xiantao.zhang@intel.com>,
	Andrew Vasquez <andrew.vasquez@qlogic.com>,
	Fenghua Yu <fenghua.yu@intel.com>, Roger Lucas <vt8231@hiddenengine.co.uk>,
	Greg Kroah-Hartman <gregkh@suse.de>,
	"James E.J. Bottomley" <James.Bottomley@suse.de>,
	Liam Girdwood <lrg@slimlogic.co.uk>,
	Tony
To: linux-kernel@vger.kernel.org
Return-path: <dri-devel-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=dri-devel>
List-Post: <mailto:dri-devel@lists.sourceforge.net>
List-Help: <mailto:dri-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/dri-devel>,
	<mailto:dri-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: dri-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Some more fixes to formats with continuation lines

Joe Perches (10):
  arch/ia64: Fix continuation line formats
  drivers/ata: Fix continuation line formats
  drivers/gpu/drm/i915/intel_bios.c: Fix continuation line formats
  drivers/hwmon/vt8231.c: Fix continuation line formats
  drivers/net/davinci_emac.c: Fix continuation line formats
  drivers/scsi/qla2xxx/qua_os.c: Fix continuation line formats
  drivers/spi/spi_s3c64xx.c: Fix continuation line formats
  drivers/staging: Fix continuation line formats
  drivers/video/via: Fix continuation line formats
  sound/soc/s3c24xx/s2c-pcm.c: Fix continuation line formats

 arch/ia64/kvm/mmio.c                   |    4 ++--
 arch/ia64/kvm/vcpu.c                   |    4 ++--
 drivers/ata/pata_at91.c                |    4 ++--
 drivers/gpu/drm/i915/intel_bios.c      |    3 +--
 drivers/hwmon/vt8231.c                 |    3 +--
 drivers/net/davinci_emac.c             |    3 +--
 drivers/scsi/qla2xxx/qla_os.c          |    4 ++--
 drivers/spi/spi_s3c64xx.c              |   11 +++++------
 drivers/staging/rtl8192su/r8192S_phy.c |   16 ++++++++--------
 drivers/staging/sep/sep_driver.c       |    5 +++--
 drivers/staging/slicoss/slicoss.c      |    6 ++----
 drivers/video/via/dvi.c                |    8 ++++----
 drivers/video/via/lcd.c                |   12 ++++++------
 sound/soc/s3c24xx/s3c-pcm.c            |    3 +--
 14 files changed, 40 insertions(+), 46 deletions(-)


------------------------------------------------------------------------------
The Planet: dedicated and managed hosting, cloud storage, colocation
Stay online with enterprise data centers and the best network in the business
Choose flexible plans and management services without long-term contracts
Personal 24x7 support from experience hosting pros just a phone call away.
http://p.sf.net/sfu/theplanet-com
--
