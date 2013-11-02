From: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
Subject: [PATCH net-next 13/13] scripts/checkpatch.pl: Add dev_kfree_skb*(NULL) check to checkpatch
Date: Sat,  2 Nov 2013 19:17:54 +0530
Message-ID: <1383400074-30555-14-git-send-email-govindarajulu90@gmail.com>
References: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Cc: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
To: davem@davemloft.net, gregkh@linuxfoundation.org,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	schwidefsky@de.ibm.com, linville@tuxdriver.com,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	IvDoorn@gmail.com, sbhatewara@vmware.com, samuel@sortiz.org,
	chas@cmf.nrl.navy.mil, roland@kernel.org, isdn@linux-pingi.de,
	jcliburn@gmail.com, benve@cisco.com, ssujith@cisco.com,
	jeffrey.t.kirsher@intel.com, jesse.brandeburg@intel.com,
	shahed.shaikh@qlogic.com, joe@perches.com, apw@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1383400074-30555-1-git-send-email-govindarajulu90@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Govindarajulu Varadarajan <govindarajulu90@gmail.com>
---
 scripts/checkpatch.pl | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/scripts/checkpatch.pl b/scripts/checkpatch.pl
index 66cad50..e651b8a 100755
--- a/scripts/checkpatch.pl
+++ b/scripts/checkpatch.pl
@@ -3719,7 +3719,7 @@ sub process {
 # check for needless "if (<foo>) fn(<foo>)" uses
 		if ($prevline =~ /\bif\s*\(\s*($Lval)\s*\)/) {
 			my $expr = '\s*\(\s*' . quotemeta($1) . '\s*\)\s*;';
-			if ($line =~ /\b(kfree|usb_free_urb|debugfs_remove(?:_recursive)?)$expr/) {
+			if ($line =~ /\b(kfree|dev_kfree_skb|dev_kfree_skb_any|dev_kfree_skb_irq|usb_free_urb|debugfs_remove(?:_recursive)?)$expr/) {
 				WARN('NEEDLESS_IF',
 				     "$1(NULL) is safe this check is probably not required\n" . $hereprev);
 			}
-- 
1.8.4.2
