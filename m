From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 38/39] wimax: export linux/wimax.h and linux/wimax/i2400m.h
	with headers_install
Date: Tue, 25 Nov 2008 23:39:34 -0800
Message-ID: <ed11bd9071b2dbb8c4d093110724b2e5e8eb9d43.1227684996.git.inaky@linux.intel.com>
References: <cover.1227684995.git.inaky@linux.intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>, wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1227684995.git.inaky@linux.intel.com>
List-Unsubscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=unsubscribe>
List-Archive: <http://lists.moblin.org/pipermail/wimax>
List-Post: <mailto:wimax@linuxwimax.org>
List-Help: <mailto:wimax-request@linuxwimax.org?subject=help>
List-Subscribe: <http://www.linuxwimax.org/mailman/listinfo/wimax>,
	<mailto:wimax-request@linuxwimax.org?subject=subscribe>
Sender: wimax-bounces@linuxwimax.org
Errors-To: wimax-bounces@linuxwimax.org
List-Id: netdev.vger.kernel.org

These two files are what user space can use to establish communication
with the WiMAX kernel API and to speak the Intel 2400m Wireless WiMAX
connection's control protocol.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: David Woodhouse <dwmw2@infradead.org>
---
 include/linux/Kbuild |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index e531783..89079ff 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -375,3 +375,5 @@ unifdef-y += xattr.h
 unifdef-y += xfrm.h
 
 objhdr-y += version.h
+header-y += wimax.h
+header-y += wimax/
-- 
1.5.6.5
