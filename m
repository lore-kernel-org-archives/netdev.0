From: Alexander Alemayhu <alexander@alemayhu.com>
Subject: [PATCH net-next] Documentation/networking: update git urls to use https over http
Date: Thu, 13 Oct 2016 17:09:51 +0200
Message-ID: <20161013150951.4615-1-alexander@alemayhu.com>
Cc: linux-doc@vger.kernel.org, linux-kernel@vger.kernel.org,
        Alexander Alemayhu <alexander@alemayhu.com>
To: netdev@vger.kernel.org, corbet@lwn.net
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This fixes the following errors when trying to clone the urls:

Cloning into 'net'...
fatal: repository 'http://git.kernel.org/cgit/linux/kernel/git/davem/net.git/' not found
Cloning into 'net-next'...
fatal: repository 'http://git.kernel.org/cgit/linux/kernel/git/davem/net-next.git/' not found
Cloning into 'linux'...
fatal: repository 'http://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/' not found
Cloning into 'stable-queue'...
fatal: repository 'http://git.kernel.org/cgit/linux/kernel/git/stable/stable-queue.git/' not found

Signed-off-by: Alexander Alemayhu <alexander@alemayhu.com>
---
 Documentation/networking/netdev-FAQ.txt | 8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/Documentation/networking/netdev-FAQ.txt b/Documentation/networking/netdev-FAQ.txt
index 0fe1c6e0dbcd..a20b2fae942b 100644
--- a/Documentation/networking/netdev-FAQ.txt
+++ b/Documentation/networking/netdev-FAQ.txt
@@ -29,8 +29,8 @@ A: There are always two trees (git repositories) in play.  Both are driven
    Linus, and net-next is where the new code goes for the future release.
    You can find the trees here:
 
-	http://git.kernel.org/?p=linux/kernel/git/davem/net.git
-	http://git.kernel.org/?p=linux/kernel/git/davem/net-next.git
+        https://git.kernel.org/pub/scm/linux/kernel/git/davem/net.git
+        https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
 
 Q: How often do changes from these trees make it to the mainline Linus tree?
 
@@ -76,7 +76,7 @@ Q: So where are we now in this cycle?
 
 A: Load the mainline (Linus) page here:
 
-	http://git.kernel.org/?p=linux/kernel/git/torvalds/linux.git
+	https://git.kernel.org/pub/scm/linux/kernel/git/torvalds/linux.git
 
    and note the top of the "tags" section.  If it is rc1, it is early
    in the dev cycle.  If it was tagged rc7 a week ago, then a release
@@ -123,7 +123,7 @@ A: Normally Greg Kroah-Hartman collects stable commits himself, but
 
    It contains the patches which Dave has selected, but not yet handed
    off to Greg.  If Greg already has the patch, then it will be here:
-	http://git.kernel.org/cgit/linux/kernel/git/stable/stable-queue.git
+	https://git.kernel.org/pub/scm/linux/kernel/git/stable/stable-queue.git
 
    A quick way to find whether the patch is in this stable-queue is
    to simply clone the repo, and then git grep the mainline commit ID, e.g.
-- 
2.10.1

