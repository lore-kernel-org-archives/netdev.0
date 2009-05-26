From: Jesper Dangaard Brouer <hawk@comx.dk>
Subject: [PATCH 1/2] Doc: seq_file.txt fix wrong dd command example.
Date: Tue, 26 May 2009 15:18:52 +0200
Message-ID: <20090526131852.7377.68330.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	"Patrick McHardy" <kaber@trash.net>,
	"Jonathan Corbet" <corbet@lwn.net>,
	Jesper Dangaard Brouer <hawk@comx.dk>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lanfw001a.cxnet.dk ([87.72.215.196]:45240 "EHLO
	lanfw001a.cxnet.dk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752967AbZEZNxD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2009 09:53:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Small error in the "dd" command example, "out=" should be "of=".

Signed-off-by: Jesper Dangaard Brouer <hawk@comx.dk>
---

 Documentation/filesystems/seq_file.txt |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/Documentation/filesystems/seq_file.txt b/Documentation/filesystems/seq_file.txt
index b843743..0d15ebc 100644
--- a/Documentation/filesystems/seq_file.txt
+++ b/Documentation/filesystems/seq_file.txt
@@ -46,7 +46,7 @@ better to do. The file is seekable, in that one can do something like the
 following:
 
     dd if=/proc/sequence of=out1 count=1
-    dd if=/proc/sequence skip=1 out=out2 count=1
+    dd if=/proc/sequence skip=1 of=out2 count=1
 
 Then concatenate the output files out1 and out2 and get the right
 result. Yes, it is a thoroughly useless module, but the point is to show

