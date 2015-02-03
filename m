From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [target:for-next 16/21] drivers/vhost/scsi.c:1081:5: sparse:
 symbol 'vhost_skip_iovec_bytes' was not declared. Should it be static?
Date: Mon, 02 Feb 2015 16:24:11 -0800
Message-ID: <1422923051.24128.5.camel@haakon3.risingtidesystems.com>
References: <201502021411.KBLYtCzS%fengguang.wu@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: kbuild-all@01.org, "Michael S. Tsirkin" <mst@redhat.com>,
	kvm@vger.kernel.org, virtualization@lists.linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	target-devel <target-devel@vger.kernel.org>
To: kbuild test robot <fengguang.wu@intel.com>
Return-path: <target-devel-owner@vger.kernel.org>
In-Reply-To: <201502021411.KBLYtCzS%fengguang.wu@intel.com>
Sender: target-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2015-02-02 at 14:25 +0800, kbuild test robot wrote:
> tree:   git://git.kernel.org/pub/scm/linux/kernel/git/nab/target-pending.git for-next
> head:   2936f1d4f3e8247bd519feba7892371d5e4c6603
> commit: 105acf608f25d5e0d9fef669299a5438b7b114ee [16/21] vhost/scsi: Add ANY_LAYOUT vhost_skip_iovec_bytes helper
> reproduce:
>   # apt-get install sparse
>   git checkout 105acf608f25d5e0d9fef669299a5438b7b114ee
>   make ARCH=x86_64 allmodconfig
>   make C=1 CF=-D__CHECK_ENDIAN__
> 
> 
> sparse warnings: (new ones prefixed by >>)
> 
> >> drivers/vhost/scsi.c:1081:5: sparse: symbol 'vhost_skip_iovec_bytes' was not declared. Should it be static?
>    drivers/vhost/scsi.c:969:1: warning: 'vhost_scsi_mapal' defined but not used [-Wunused-function]
>     vhost_scsi_mapal(struct tcm_vhost_cmd *cmd, int max_niov,
>     ^
> 
> Please review and possibly fold the followup patch.

Fixing up for -v3.

Thanks Fengguang!

--nab
