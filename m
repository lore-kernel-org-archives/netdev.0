From: Masanari Iida <standby24x7@gmail.com>
Subject: [PATCH] [trivial]doc:networking: Fix typo in documentation/networking
Date: Sat, 25 May 2013 02:05:59 +0900
Message-ID: <1369415159-22856-1-git-send-email-standby24x7@gmail.com>
Cc: Masanari Iida <standby24x7@gmail.com>
To: trivial@kernel.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Correct spelling typo

Signed-off-by: Masanari Iida <standby24x7@gmail.com>

---
 Documentation/networking/ifenslave.c      |  2 +-
 Documentation/networking/ip-sysctl.txt    |  2 +-
 Documentation/networking/netlink_mmap.txt | 14 +++++++-------
 3 files changed, 9 insertions(+), 9 deletions(-)

diff --git a/Documentation/networking/ifenslave.c b/Documentation/networking/ifenslave.c
index ac5debb..9f6a8ff 100644
--- a/Documentation/networking/ifenslave.c
+++ b/Documentation/networking/ifenslave.c
@@ -501,7 +501,7 @@ out:
 
 static short mif_flags;
 
-/* Get the inteface configuration from the kernel. */
+/* Get the interface configuration from the kernel. */
 static int if_getconfig(char *ifname)
 {
 	struct ifreq ifr;
diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index f98ca63..398d0fb 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -183,7 +183,7 @@ tcp_early_retrans - INTEGER
 	for triggering fast retransmit when the amount of outstanding data is
 	small and when no previously unsent data can be transmitted (such
 	that limited transmit could be used). Also controls the use of
-	Tail loss probe (TLP) that converts RTOs occuring due to tail
+	Tail loss probe (TLP) that converts RTOs occurring due to tail
 	losses into fast recovery (draft-dukkipati-tcpm-tcp-loss-probe-01).
 	Possible values:
 		0 disables ER
diff --git a/Documentation/networking/netlink_mmap.txt b/Documentation/networking/netlink_mmap.txt
index 1c2dab4..e6088ba 100644
--- a/Documentation/networking/netlink_mmap.txt
+++ b/Documentation/networking/netlink_mmap.txt
@@ -54,7 +54,7 @@ it will use an allocated socket buffer as usual and the contents will be
  copied to the ring on transmission, nullifying most of the performance gains.
 Dumps of kernel databases automatically support memory mapped I/O.
 
-Conversion of the transmit path involves changing message contruction to
+Conversion of the transmit path involves changing message construction to
 use memory from the TX ring instead of (usually) a buffer declared on the
 stack and setting up the frame header approriately. Optionally poll() can
 be used to wait for free frames in the TX ring.
@@ -65,8 +65,8 @@ Structured and definitions for using memory mapped I/O are contained in
 RX and TX rings
 ----------------
 
-Each ring contains a number of continous memory blocks, containing frames of
-fixed size dependant on the parameters used for ring setup.
+Each ring contains a number of continuous memory blocks, containing frames of
+fixed size dependent on the parameters used for ring setup.
 
 Ring:	[ block 0 ]
 		[ frame 0 ]
@@ -80,7 +80,7 @@ Ring:	[ block 0 ]
 		[ frame 2 * n + 1 ]
 
 The blocks are only visible to the kernel, from the point of view of user-space
-the ring just contains the frames in a continous memory zone.
+the ring just contains the frames in a continuous memory zone.
 
 The ring parameters used for setting up the ring are defined as follows:
 
@@ -91,7 +91,7 @@ struct nl_mmap_req {
 	unsigned int	nm_frame_nr;
 };
 
-Frames are grouped into blocks, where each block is a continous region of memory
+Frames are grouped into blocks, where each block is a continuous region of memory
 and holds nm_block_size / nm_frame_size frames. The total number of frames in
 the ring is nm_frame_nr. The following invariants hold:
 
@@ -113,8 +113,8 @@ Some parameters are constrained, specifically:
 
 - nm_frame_nr must equal the actual number of frames as specified above.
 
-When the kernel can't allocate phsyically continous memory for a ring block,
-it will fall back to use physically discontinous memory. This might affect
+When the kernel can't allocate phsyically continuous memory for a ring block,
+it will fall back to use physically discontinuous memory. This might affect
 performance negatively, in order to avoid this the nm_frame_size parameter
 should be chosen to be as small as possible for the required frame size and
 the number of blocks should be increased instead.
-- 
1.8.3.rc3
