From: kbuild test robot <fengguang.wu@intel.com>
Subject: [target:for-next 16/21] drivers/vhost/scsi.c:1081:5: sparse: symbol
	'vhost_skip_iovec_bytes' was not declared. Should it be static?
Date: Mon, 2 Feb 2015 14:25:21 +0800
Message-ID: <201502021411.KBLYtCzS%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: kvm@vger.kernel.org, "Michael S. Tsirkin" <mst@redhat.com>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	virtualization@lists.linux-foundation.org, kbuild-all@01.org
To: Nicholas Bellinger <nab@linux-iscsi.org>
Return-path: <virtualization-bounces@lists.linux-foundation.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

tree:   git://git.kernel.org/pub/scm/linux/kernel/git/nab/target-pending.git for-next
head:   2936f1d4f3e8247bd519feba7892371d5e4c6603
commit: 105acf608f25d5e0d9fef669299a5438b7b114ee [16/21] vhost/scsi: Add ANY_LAYOUT vhost_skip_iovec_bytes helper
reproduce:
  # apt-get install sparse
  git checkout 105acf608f25d5e0d9fef669299a5438b7b114ee
  make ARCH=x86_64 allmodconfig
  make C=1 CF=-D__CHECK_ENDIAN__


sparse warnings: (new ones prefixed by >>)

>> drivers/vhost/scsi.c:1081:5: sparse: symbol 'vhost_skip_iovec_bytes' was not declared. Should it be static?
   drivers/vhost/scsi.c:969:1: warning: 'vhost_scsi_mapal' defined but not used [-Wunused-function]
    vhost_scsi_mapal(struct tcm_vhost_cmd *cmd, int max_niov,
    ^

Please review and possibly fold the followup patch.

---
0-DAY kernel test infrastructure                Open Source Technology Center
http://lists.01.org/mailman/listinfo/kbuild                 Intel Corporation
