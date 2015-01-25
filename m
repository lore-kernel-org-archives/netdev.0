From: Nicholas Mc Guire <der.herr@hofr.at>
Subject: [PATCH 3/3] hyperv: hid-hyperv.c:
 fixup-of-wait_for_completion_timeout-return-type
Date: Sun, 25 Jan 2015 12:00:53 +0100
Message-ID: <1422183653-7541-1-git-send-email-der.herr@hofr.at>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jiri Kosina <jkosina@suse.cz>, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, Nicholas Mc Guire <der.herr@hofr.at>,
 netdev@vger.kernel.org, devel@linuxdriverproject.org
To: "K. Y. Srinivasan" <kys@microsoft.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Signed-off-by: Nicholas Mc Guire <der.herr@hofr.at>
---

The return type of wait_for_completion_timeout is unsigned long not
int. This patch fixes up the declarations only.

Patch was compile tested only for x86_64_defconfig + CONFIG_X86_VSMP=y
CONFIG_HYPERV=m, CONFIG_HID_HYPERV_MOUSE=m

Patch is against 3.19.0-rc5 -next-20150123

 drivers/hid/hid-hyperv.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/hid/hid-hyperv.c b/drivers/hid/hid-hyperv.c
index 31fad64..6039f07 100644
--- a/drivers/hid/hid-hyperv.c
+++ b/drivers/hid/hid-hyperv.c
@@ -381,7 +381,7 @@ static void mousevsc_on_channel_callback(void *context)
 static int mousevsc_connect_to_vsp(struct hv_device *device)
 {
 	int ret = 0;
-	int t;
+	unsigned long t;
 	struct mousevsc_dev *input_dev = hv_get_drvdata(device);
 	struct mousevsc_prt_msg *request;
 	struct mousevsc_prt_msg *response;
-- 
1.7.10.4
