From: "Nicholas A. Bellinger" <nab@linux-iscsi.org>
Subject: Re: [PATCH 19/23] target: use per-attribute show and store methods
Date: Sat, 26 Sep 2015 16:35:16 -0700
Message-ID: <1443310516.7042.24.camel@haakon3.risingtidesystems.com>
References: <1443189000-13398-1-git-send-email-hch@lst.de>
	 <1443189000-13398-20-git-send-email-hch@lst.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Joel Becker <jlbec@evilplan.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Felipe Balbi <balbi@ti.com>, Tejun Heo <tj@kernel.org>,
	Pratyush Anand <pratyush.anand@gmail.com>,
	target-devel@vger.kernel.org, cluster-devel@redhat.com,
	ocfs2-devel@oss.oracle.com, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org
To: Christoph Hellwig <hch@lst.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.linux-iscsi.org ([67.23.28.174]:40630 "EHLO
	linux-iscsi.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750874AbbIZXfS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Sep 2015 19:35:18 -0400
In-Reply-To: <1443189000-13398-20-git-send-email-hch@lst.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-09-25 at 06:49 -0700, Christoph Hellwig wrote:
> This also allows to remove the target-specific old configfs macros, and
> gets rid of the target_core_fabric_configfs.h header which only had one
> function declaration left that could be moved to a better place.
> 
> Signed-off-by: Christoph Hellwig <hch@lst.de>
> ---
>  Documentation/target/tcm_mod_builder.py      |   17 -
>  drivers/infiniband/ulp/srpt/ib_srpt.c        |   78 +-
>  drivers/scsi/qla2xxx/tcm_qla2xxx.c           |  153 ++--
>  drivers/target/iscsi/iscsi_target_configfs.c |  791 ++++++-----------
>  drivers/target/iscsi/iscsi_target_stat.c     |  666 ++++++--------
>  drivers/target/loopback/tcm_loop.c           |   60 +-
>  drivers/target/sbp/sbp_target.c              |   87 +-
>  drivers/target/target_core_configfs.c        | 1209 ++++++++++----------------
>  drivers/target/target_core_fabric_configfs.c |  275 ++----
>  drivers/target/target_core_internal.h        |    3 +
>  drivers/target/target_core_stat.c            |  918 ++++++++-----------
>  drivers/target/tcm_fc/tfc_cmd.c              |    1 -
>  drivers/target/tcm_fc/tfc_conf.c             |   44 +-
>  drivers/target/tcm_fc/tfc_io.c               |    1 -
>  drivers/target/tcm_fc/tfc_sess.c             |    1 -
>  drivers/usb/gadget/legacy/tcm_usb_gadget.c   |   44 +-
>  drivers/vhost/scsi.c                         |   41 +-
>  drivers/xen/xen-scsiback.c                   |   32 +-
>  include/target/configfs_macros.h             |  147 ----
>  include/target/target_core_base.h            |   60 ++
>  include/target/target_core_fabric_configfs.h |  122 ---
>  21 files changed, 1689 insertions(+), 3061 deletions(-)
>  delete mode 100644 include/target/configfs_macros.h
>  delete mode 100644 include/target/target_core_fabric_configfs.h
> 

I'm totally crazy for this patch.

Very nice work to drop this much boilerplate macro-fu in target-core +
fabric driver code.

Reviewed-by: Nicholas Bellinger <nab@linux-iscsi.org>
Acked-by: Nicholas Bellinger <nab@linux-iscsi.org>
