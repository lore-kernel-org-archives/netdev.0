From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH] wimax: fix typo in kernel-doc for debugfs_dentry in struct
	wimax_dev
Date: Fri,  9 Jan 2009 09:34:00 -0800
Message-ID: <1231522440-30059-1-git-send-email-inaky@linux.intel.com>
References: <4966E268.20101@oracle.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
To: wimax@linuxwimax.org,
	netdev@vger.kernel.org
Return-path: <wimax-bounces@linuxwimax.org>
In-Reply-To: <4966E268.20101@oracle.com>
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

The kernel-doc was referring to member @debufs_dentry instead of
@debugfs_dentry.

Reported by Randy Dunlap http://marc.info/?l=linux-netdev&m=123147942302885&w=2

As well, escape the colon in the field's text description, as it is
causing the generated text to be erraticly broken up (with paragraphs
moved down). Could not find a reason why it is happening so, even when
other field descriptions use colons and work as expected.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Cc: Randy Dunlap <randy.dunlap@oracle.com>
---
 include/net/wimax.h |    4 ++--
 1 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/include/net/wimax.h b/include/net/wimax.h
index 073809c..6b3824e 100644
--- a/include/net/wimax.h
+++ b/include/net/wimax.h
@@ -323,8 +323,8 @@ struct input_dev;
  *
  * @rf_hw: [private] State of the hardware radio switch (OFF/ON)
  *
- * @debufs_dentry: [private] Used to hook up a debugfs entry. This
- *     shows up in the debugfs root as wimax:DEVICENAME.
+ * @debugfs_dentry: [private] Used to hook up a debugfs entry. This
+ *     shows up in the debugfs root as wimax\:DEVICENAME.
  *
  * Description:
  * This structure defines a common interface to access all WiMAX
-- 
1.5.6.5
