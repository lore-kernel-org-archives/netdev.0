From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: manual merge of the net tree with the acpi tree
Date: Thu, 3 Mar 2011 13:44:26 +1100
Message-ID: <20110303134426.5814008c.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Huang Ying <ying.huang@intel.com>, Len Brown <lenb@kernel.org>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

Today's linux-next merge of the net tree got a conflict in lib/Makefile
between commit 248852b614cb7713552188a9c2552ba774945733 ("lib, Add
lock-less NULL terminated single list") from the acpi tree and commitc
39649c331c70952700f99832b03f87e9d7f5b4b ("lib: cpu_rmap: CPU affinity
reverse-mapping") from the net tree.

Just overlapping additions. I fixed it up (see below) and can carry the
fix as necessary.
-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au

diff --cc lib/Makefile
index 7cb0608,b73ba01..0000000
--- a/lib/Makefile
+++ b/lib/Makefile
@@@ -110,8 -110,8 +110,10 @@@ obj-$(CONFIG_ATOMIC64_SELFTEST) += atom
  
  obj-$(CONFIG_AVERAGE) += average.o
  
 +obj-$(CONFIG_LLIST) += llist.o
 +
+ obj-$(CONFIG_CPU_RMAP) += cpu_rmap.o
+ 
  hostprogs-y   := gen_crc32table
  clean-files   := crc32table.h
  
