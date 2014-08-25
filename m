From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next] neigh: document gc_thresh2
Date: Mon, 25 Aug 2014 15:05:30 -0700
Message-ID: <20140825150530.29573594@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-doc@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Randy Dunlap <rdunlap@infradead.org>
Return-path: <linux-doc-owner@vger.kernel.org>
Sender: linux-doc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Missing documentation for gc_thresh2 sysctl.

Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

--- a/Documentation/networking/ip-sysctl.txt	2014-08-12 13:07:41.000000000 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2014-08-22 12:19:05.020051095 -0700
@@ -65,6 +65,12 @@ neigh/default/gc_thresh1 - INTEGER
 	purge entries if there are fewer than this number.
 	Default: 128
 
+neigh/default/gc_thresh2 - INTEGER
+	Threshold when garbage collector becomes more aggressive about
+	purging entries. Entries older than 5 seconds will be cleared
+	when over this number.
+	Default: 512
+
 neigh/default/gc_thresh3 - INTEGER
 	Maximum number of neighbor entries allowed.  Increase this
 	when using large numbers of interfaces and when communicating
