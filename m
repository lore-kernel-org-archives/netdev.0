From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 28/29] wimax: export linux/wimax.h and linux/wimax/i2400m.h
	with headers_install
Date: Mon, 15 Dec 2008 04:58:23 -0800
Message-ID: <0c32f95bc76a1fbb8e3f4fdb1d84eaa6cb1b32f7.1229345780.git.inaky@linux.intel.com>
References: <cover.1229345769.git.inaky@linux.intel.com>
Cc: greg@kroah.com, David Woodhouse <dwmw2@infradead.org>, wimax@linuxwimax.org
To: netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <cover.1229345769.git.inaky@linux.intel.com>
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
 include/linux/Kbuild       |    2 ++
 include/linux/wimax/Kbuild |    1 +
 2 files changed, 3 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/wimax/Kbuild

diff --git a/include/linux/Kbuild b/include/linux/Kbuild
index e531783..89079ff 100644
--- a/include/linux/Kbuild
+++ b/include/linux/Kbuild
@@ -375,3 +375,5 @@ unifdef-y += xattr.h
 unifdef-y += xfrm.h
 
 objhdr-y += version.h
+header-y += wimax.h
+header-y += wimax/
diff --git a/include/linux/wimax/Kbuild b/include/linux/wimax/Kbuild
new file mode 100644
index 0000000..3cb4f26
--- /dev/null
+++ b/include/linux/wimax/Kbuild
@@ -0,0 +1 @@
+header-y += i2400m.h
-- 
1.5.6.5
