From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/11] treewide: Remove pr_<level> uses with KERN_<level>
Date: Sat, 11 Sep 2010 22:10:48 -0700
Message-ID: <cover.1284267142.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, alsa-devel@alsa-project.org,
	Marcelo Tosatti <mtosatti@redhat.com>, kvm@vger.kernel.org,
	Takashi Iwai <tiwai@suse.de>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	Steve Wise <swise@opengridcomputing.com>,
	Tom Tucker <tom@opengridcomputing.com>, Jaroslav Kysela <perex@perex.cz>,
	Paul Mackerras <paulus@samba.org>, "H. Peter Anvin" <hpa@zytor.com>,
	Sean Hefty <sean.hefty@intel.com>, devel@driverdev.osuosl.org,
	David Brownell <dbrownell@users.sourceforge.net>,
	Russell King <linux@arm.linux.org.uk>,
	linux-rdma@vger.kernel.org, x86@kernel.org,
	Alexander Graf <agraf@suse.de>, Ingo Molnar <mingo@redhat.com>,
	Avi Kivity <avi@redhat.com>, Roland Dreier <rolandd@cisco.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>, cbe-oss-dev@lists.ozlabs.org,
	Mark Brown <broonie@opensource.wolfsonmicro.com>,
	microblaze-uclinux@itee.uq.edu.au, kvm-ppc@vger.kern
To: Jiri Kosina <trivial@kernel.org>
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

Most of these are pr_debug(KERN_<foo>.
pr_<level>(KERN_<level> is unnecessary.

Joe Perches (11):
  arch/arm: Remove pr_<level> uses of KERN_<level>
  arch/avr32: Remove pr_<level> uses of KERN_<level>
  arch/microblaze: Remove pr_<level> uses of KERN_<level>
  arch/mips: Remove pr_<level> uses of KERN_<level>
  arch/powerpc: Remove pr_<level> uses of KERN_<level>
  arch/x86: Remove pr_<level> uses of KERN_<level>
  drivers/infiniband: Remove pr_<level> uses of KERN_<level>
  drivers/net/skfp: Remove pr_<level> uses of KERN_<level>
  drivers/staging/msm: Remove pr_<level> uses of KERN_<level>
  drivers/usb/gadget: Remove pr_<level> uses of KERN_<level>
  sound: Remove pr_<level> uses of KERN_<level>

 arch/arm/mach-pxa/cpufreq-pxa2xx.c       |    3 +-
 arch/avr32/mach-at32ap/at32ap700x.c      |    4 +-
 arch/microblaze/kernel/exceptions.c      |   16 ++----
 arch/mips/kernel/irq-gic.c               |    2 +-
 arch/mips/pci/pci-rc32434.c              |    2 +-
 arch/powerpc/kvm/emulate.c               |    4 +-
 arch/powerpc/sysdev/pmi.c                |    2 +-
 arch/x86/kernel/apb_timer.c              |    4 +-
 drivers/infiniband/hw/amso1100/c2_intr.c |    4 +-
 drivers/net/skfp/skfddi.c                |   84 +++++++++++++++---------------
 drivers/staging/msm/staging-devices.c    |    2 +-
 drivers/usb/gadget/r8a66597-udc.c        |    2 +-
 sound/ppc/snd_ps3.c                      |    2 +-
 sound/soc/s3c24xx/s3c-dma.c              |    3 +-
 14 files changed, 64 insertions(+), 70 deletions(-)

-- 
1.7.3.rc1
