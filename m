From: David Howells <dhowells@redhat.com>
Subject: [PATCH 1/3] AFS: Export a couple of core functions for AFS write
	support
Date: Tue, 08 May 2007 20:43:59 +0100
Message-ID: <20070508194358.27477.74888.stgit@warthog.cambridge.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	dhowells@redhat.com
To: akpm@osdl.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S967983AbXEHTpB@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Export a couple of core functions for AFS write support to use:

	find_get_pages_contig()
	find_get_pages_tag()

Signed-off-by: David Howells <dhowells@redhat.com>
---

 mm/filemap.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/mm/filemap.c b/mm/filemap.c
index 5631d6b..b276508 100644
--- a/mm/filemap.c
+++ b/mm/filemap.c
@@ -750,6 +750,7 @@ unsigned find_get_pages_contig(struct address_space *mapping, pgoff_t index,
 	read_unlock_irq(&mapping->tree_lock);
 	return i;
 }
+EXPORT_SYMBOL(find_get_pages_contig);
 
 /**
  * find_get_pages_tag - find and return pages that match @tag
@@ -778,6 +779,7 @@ unsigned find_get_pages_tag(struct address_space *mapping, pgoff_t *index,
 	read_unlock_irq(&mapping->tree_lock);
 	return ret;
 }
+EXPORT_SYMBOL(find_get_pages_tag);
 
 /**
  * grab_cache_page_nowait - returns locked page at given index in given cache
