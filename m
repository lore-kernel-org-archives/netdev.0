From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: Distributed storage release.
Date: Wed, 15 Oct 2008 03:23:50 +0400
Message-ID: <20081014232350.GA27915@2ka.mipt.ru>
References: <20081013172038.GA18762@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-fsdevel@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081013172038.GA18762@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

On Mon, Oct 13, 2008 at 09:20:38PM +0400, Evgeniy Polyakov (johnpol@2ka.mipt.ru) wrote:
> I am pleased to announce new distributed storage (DST) project release.
> This release increases size of the patch by 10% by providing lots of
> comments on how code works. Also cleaned up number of pointed issues:
> kzalloc/kcalloc, style, config deps and so on.

Just in case you will want to apply it to the latest tree and compile,
following patch is needed to properly work with 2.6.27 tree.
2.6.26 (as what it was against) does not need this.

diff --git a/drivers/block/dst/dcore.c b/drivers/block/dst/dcore.c
index d58eb93..039d59b 100644
--- a/drivers/block/dst/dcore.c
+++ b/drivers/block/dst/dcore.c
@@ -24,6 +24,7 @@
 #include <linux/jhash.h>
 #include <linux/idr.h>
 #include <linux/init.h>
+#include <linux/namei.h>
 #include <linux/slab.h>
 #include <linux/socket.h>
 

-- 
	Evgeniy Polyakov
