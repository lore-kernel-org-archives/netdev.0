From: Stefan Agner <stefan@agner.ch>
Subject: [PATCH v2] net: cx89x0: move attribute declaration before struct keyword
Date: Mon, 17 Apr 2017 13:54:34 -0700
Message-ID: <20170417205434.12663-1-stefan@agner.ch>
Cc: shc_work@mail.ru, jarod@redhat.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Stefan Agner <stefan@agner.ch>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The attribute declaration is typically before the definition. Move
the __maybe_unused attribute declaration before the struct keyword.

Signed-off-by: Stefan Agner <stefan@agner.ch>
---
Changes in v2:
- Move __maybe_unused after the complete type

 drivers/net/ethernet/cirrus/cs89x0.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethernet/cirrus/cs89x0.c
index 3647b28e8de0..47384f7323ac 100644
--- a/drivers/net/ethernet/cirrus/cs89x0.c
+++ b/drivers/net/ethernet/cirrus/cs89x0.c
@@ -1896,7 +1896,7 @@ static int cs89x0_platform_remove(struct platform_device *pdev)
 	return 0;
 }
 
-static const struct __maybe_unused of_device_id cs89x0_match[] = {
+static const struct of_device_id __maybe_unused cs89x0_match[] = {
 	{ .compatible = "cirrus,cs8900", },
 	{ .compatible = "cirrus,cs8920", },
 	{ },
-- 
2.12.2
