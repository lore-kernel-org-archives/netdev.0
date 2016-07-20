From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the cgroup tree with the net-next tree
Date: Wed, 20 Jul 2016 16:11:36 +1000
Message-ID: <20160720161136.3e3cc89a@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Martin KaFai Lau <kafai@fb.com>,
	Wei Yongjun <yongjun_wei@trendmicro.com.cn>
To: Tejun Heo <tj@kernel.org>, David Miller <davem@davemloft.net>,
	<netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Tejun,

Today's linux-next merge of the cgroup tree got a conflict in:

  kernel/cgroup.c

between commit:

  1f3fe7ebf613 ("cgroup: Add cgroup_get_from_fd")

from the net-next tree and commit:

  55094f575358 ("cgroup: remove duplicated include from cgroup.c")

from the cgroup tree.

I fixed it up (see below) and can carry the fix as necessary. This
is now fixed as far as linux-next is concerned, but any non trivial
conflicts should be mentioned to your upstream maintainer when your tree
is submitted for merging.  You may also want to consider cooperating
with the maintainer of the conflicting tree to minimise any particularly
complex conflicts.

-- 
Cheers,
Stephen Rothwell

diff --cc kernel/cgroup.c
index 50787cd61da2,cb7cc54e2716..000000000000
--- a/kernel/cgroup.c
+++ b/kernel/cgroup.c
@@@ -61,8 -61,6 +61,7 @@@
  #include <linux/cpuset.h>
  #include <linux/proc_ns.h>
  #include <linux/nsproxy.h>
- #include <linux/proc_ns.h>
 +#include <linux/file.h>
  #include <net/sock.h>
  
  /*
