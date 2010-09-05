From: Joe Perches <joe@perches.com>
Subject: [PATCH 00/13] trivial: Remove unnecessary casts of private_data
Date: Sat,  4 Sep 2010 18:52:41 -0700
Message-ID: <cover.1283650107.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: alsa-devel@alsa-project.org, David Airlie <airlied@linux.ie>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	dri-devel@lists.freedesktop.org, Jaroslav Kysela <perex@perex.cz>,
	"J. Bruce Fields" <bfields@fieldses.org>,
	Adaptec OEM Raid Solutions <aacraid@adaptec.com>,
	Wey-Yi Guy <wey-yi.w.guy@intel.com>,
	Sean Hefty <sean.hefty@intel.com>, devel@driverdev.osuosl.org,
	linux-s390@vger.kernel.org, "Pekka Savola \(ipv6\)" <pekkas@netcore.fi>,
	linux-scsi@vger.kernel.org, linux-rdma@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Intel Linux Wireless <ilw@linux.intel.com>,
	Neil Brown <neilb@suse.de>, Ingo Molnar <mingo@redhat.com>,
	Doug Gilbert <dgilbert@interlog.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>, Roland Dreier <rolandd@cisco.com>,
	Hal Rosenstock <hal.rosenstock@gmail.com>,
	Trond Myklebust <Trond.Myklebust@netapp.com>,
	ecryptfs-devel@lists.launchpad.net,
	"John W.
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

Resend removal of remaining casts of private_data

Joe Perches (13):
  drivers/gpu/drm: Remove unnecessary casts of private_data
  drivers/infiniband: Remove unnecessary casts of private_data
  drivers/net/wireless/iwlwifi: Remove unnecessary casts of private_data
  drivers/s390: Remove unnecessary casts of private_data
  drivers/scsi: Remove unnecessary casts of private_data
  drivers/staging/lirc: Remove unnecessary casts of private_data
  fs/ecryptfs: Remove unnecessary casts of private_data
  fs/seq_file.c: Remove unnecessary casts of private_data
  kernel/pm_qos_params.c: Remove unnecessary casts of private_data
  kernel/trace: Remove unnecessary casts of private_data
  net/ipv4: Remove unnecessary casts of private_data
  net/sunrpc/rpc_pipe.c: Remove unnecessary casts of private_data
  sound: Remove unnecessary casts of private_data

 drivers/gpu/drm/radeon/radeon_ttm.c            |    2 +-
 drivers/gpu/drm/vmwgfx/vmwgfx_fifo.c           |    2 +-
 drivers/gpu/drm/vmwgfx/vmwgfx_ttm_glue.c       |    2 +-
 drivers/infiniband/hw/qib/qib_file_ops.c       |    4 ++--
 drivers/net/wireless/iwlwifi/iwl-agn-debugfs.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-debugfs.c     |    4 ++--
 drivers/s390/char/vmcp.c                       |    6 +++---
 drivers/scsi/aacraid/linit.c                   |    2 +-
 drivers/scsi/sg.c                              |    2 +-
 drivers/staging/lirc/lirc_imon.c               |    4 ++--
 drivers/staging/lirc/lirc_zilog.c              |   10 +++++-----
 fs/ecryptfs/ecryptfs_kernel.h                  |    2 +-
 fs/seq_file.c                                  |    6 +++---
 kernel/pm_qos_params.c                         |    2 +-
 kernel/trace/ftrace.c                          |    4 ++--
 kernel/trace/trace.c                           |    2 +-
 net/ipv4/raw.c                                 |    2 +-
 net/sunrpc/rpc_pipe.c                          |    4 ++--
 sound/core/oss/mixer_oss.c                     |   22 +++++++++++-----------
 sound/core/pcm.c                               |    3 +--
 sound/drivers/virmidi.c                        |    2 +-
 sound/i2c/other/ak4xxx-adda.c                  |    2 +-
 sound/isa/ad1816a/ad1816a.c                    |    2 +-
 sound/isa/azt2320.c                            |    2 +-
 sound/isa/gus/gusmax.c                         |    4 ++--
 sound/isa/sb/sb8.c                             |    2 +-
 sound/oss/au1550_ac97.c                        |   18 +++++++++---------
 sound/pci/emu10k1/emumpu401.c                  |    2 +-
 sound/pci/ice1712/pontis.c                     |    6 +++---
 sound/pci/ice1712/prodigy192.c                 |    2 +-
 sound/pci/rme96.c                              |    8 ++++----
 sound/pci/rme9652/hdsp.c                       |    8 ++++----
 32 files changed, 72 insertions(+), 73 deletions(-)

-- 
1.7.2.19.g9a302
