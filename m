From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: [1/3] POHMELFS: vfs changes.
Date: Wed, 8 Oct 2008 01:20:25 +0400
Message-ID: <20081007212025.GA12380@2ka.mipt.ru>
References: <20081007211925.GA1274@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20081007211925.GA1274@2ka.mipt.ru>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Evgeniy Polyakov <johnpol@2ka.mipt.ru>

diff --git a/mm/filemap.c b/mm/filemap.c
index 07e9d92..57beb4b 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -495,6 +495,7 @@ int add_to_page_cache_lru(struct page *page, struct address_space *mapping,
 		lru_cache_add(page);
 	return ret;
 }
+EXPORT_SYMBOL_GPL(add_to_page_cache_lru);
 
 #ifdef CONFIG_NUMA
 struct page *__page_cache_alloc(gfp_t gfp)
@@ -610,6 +611,7 @@ int __lock_page_killable(struct page *page)
 	return __wait_on_bit_lock(page_waitqueue(page), &wait,
 					sync_page_killable, TASK_KILLABLE);
 }
+EXPORT_SYMBOL_GPL(__lock_page_killable);
 
 /**
  * __lock_page_nosync - get a lock on the page, without calling sync_page()


-- 
	Evgeniy Polyakov
