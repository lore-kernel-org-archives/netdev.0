From: Maciej Sosnowski <maciej.sosnowski@intel.com>
Subject: [PATCH 4/4] dca: fixup initialization dependency
Date: Fri, 07 Nov 2008 12:47:17 +0100
Message-ID: <20081107114704.25190.24427.stgit@linux.site>
References: <20081107114325.25190.5419.stgit@linux.site>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tom.s.picard@intel.com, mark_rustad@Xiotech.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	stable@kernel.org
To: dan.j.williams@intel.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754700AbYKGL7A@vger.kernel.org>
In-Reply-To: <20081107114325.25190.5419.stgit@linux.site>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dan Williams <dan.j.williams@intel.com>

Mark dca_init as a subsys_initcall since it needs to be ready to go
before dependent drivers start registering themselves.

Cc: <stable@kernel.org>
Reported-and-tested-by: Mark Rustad <mark_rustad@Xiotech.com>
Acked-by: Maciej Sosnowski <maciej.sosnowski@intel.com>
Signed-off-by: Dan Williams <dan.j.williams@intel.com>
---

 drivers/dca/dca-core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/dca/dca-core.c b/drivers/dca/dca-core.c
index ec249d2..d883e1b 100644
--- a/drivers/dca/dca-core.c
+++ b/drivers/dca/dca-core.c
@@ -270,6 +270,6 @@ static void __exit dca_exit(void)
 	dca_sysfs_exit();
 }
 
-module_init(dca_init);
+subsys_initcall(dca_init);
 module_exit(dca_exit);
 
