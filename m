From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 61/64] Bluetooth: Separate btmrvl_register_hdev() from btmrvl_add_card()
Date: Mon, 10 May 2010 11:37:51 +0200
Message-ID: <64061607eab7cb146115927cb596de123c542d45.1273484099.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
 <fe1aff710756ac73c455d214845c74e304d0e966.1273484095.git.marcel@holtmann.org>
 <acce90d6a957812081b83ac4d1133e93a43569c6.1273484095.git.marcel@holtmann.org>
 <4f7ac1814ef6f0773e57ffd159a1dd57a3c80521.1273484095.git.marcel@holtmann.org>
 <0d861d8b8edd139a9b291cb262d08dec8dc3922d.1273484095.git.marcel@holtmann.org>
 <b9dbdbc1f4404cba2e64939c30c87d59c9796e4e.1273484095.git.marcel@holtmann.org>
 <c69163e9ed5048407cc84f439cbfecc53f6f7131.1273484095.git.marcel@holtmann.org>
 <faaebd192ec9c3febcab98149d1309199a5b886c.1273484095.git.marcel@holtmann.org>
 <7dffe4210233a2860c3f41477c40b3252edf2b7d.1273484095.git.marcel@holtmann.org>
 <d1daa091e8612f3aab14d28b5836375fafe155e1.1273484096.git.marcel@holtmann.org>
 <e8235c6bdd1c7ffbaa7eb8dcdbb46c51f1e5d72e.1273484096.git.marcel@holtmann.org>
 <d5392c8f1e9faef089bb7cb66c3314da8bddd1fe.1273484096.git.marcel@holtmann.org>
 <1d8f5d16913d74e428950ee02fe9ff7e6391c120.1273484096.git.marcel@holtmann.org>
 <277ffbe362823d18a17792fbd8e507010e666299.1273484096.git.marcel@holtmann.org>
 <36f2fd585f43199f006a3b5ff84e95815102cd31.1273484096.git.marcel@holtmann.org>
 <9e917af13d59182f95bbb5483dc0c4254dfb7944.1273484096.git.marcel@holtmann.org>
 <f0946ccfc7da403a46b7ff7cb2e3deffac108742.1273484096.git.marcel@holtmann.org>
 <73edaa9933219e25d6733b78d1e2c881025705e2.1273484096.git.marcel@holtmann.org>
 <e072745f4adb01b909bd08a0cfc8f79348f4d2c6.1273484096.git.marcel@holtmann.org>
 <99b0d4b7b09edeacf4542bced5c01239375b51a9.1273484096.git.marcel@holtmann.org>
 <6e3a59819fac19006fe4255b87928e5a12c54532.1273484096.git.marcel@holtmann.org>
 <8abb52ee00c4b3f857269eb6b7145991bab869bf.1273484096.git.marcel@holtmann.org>
 <05fbd89dd4153341717b33d9e8ae8bd29db6c1c8.1273484096.git.marcel@holtmann.org>
 <c1b4f43be01c2a363be021485dd18cca33cfab8a.1273484097.git.marcel@holtmann.org>
 <2fb862e215e53630066c677e06d7551fa38bf235.1273484097.git.marcel@holtmann.org>
 <7b1c0049be3aabc18831ada339dbcf41ba8c81fd.1273484097.git.marcel@holtmann.org>
 <1c7621596d11b9c3e19eb88a818758dee4901c95.1273484097.git.marcel@holtmann.org>
 <10467e9e9b89272b25b56688bb276d0830e9ab9a.1273484097.git.marcel@holtmann.org>
 <052897ca5019d9157ae09e5e84eee2a9ef5dccc6.1273484097.git.marcel@holtmann.org>
 <855666cccc939d392316de17512e17a08b2fa05a.1273484097.git.marcel@holtmann.org>
 <14b5aa71ec506f4e38ca6a1dc02ecd668ecfd902.1273484097.git.marcel@holtmann.org>
 <803020c6fa63aa738cfda3329c9675b42023e9d2.1273484097.git.marcel@holtmann.org>
 <369ba30264826f38eefc61b93688100be8adbd4d.1273484097.git.marcel@holtmann.org>
 <68d7f0ce911e41e463c45911be031cdf6a096fe8.1273484097.git.marcel@holtmann.org>
 <f6e6b16823de0aff31cb8ee8c098383e3aceec58.1273484097.git.marcel@holtmann.org>
 <0ee0d20855ae9271de3f6695f4cafc08ab2533bb.1273484097.git.marcel@holtmann.org>
 <812e737e29a1d559e7bfbea675fdcfcbad9f5e1f.1273484097.git.marcel@holtmann.org>
 <3b1a9f3fa6ad842991538da2c3b2e29e047b131f.1273484097.git.marcel@holtmann.org>
 <84fb0a6334af0ccad3544f6972c055d90fbb9fbe.1273484097.git.marcel@holtmann.org>
 <bd3c9e255e76ae232d417e3914ca5d80ca3e9485.1273484097.git.marcel@holtmann.org>
 <0041ecfa3025d7612fdaab12b2f07c9c3c09f42f.1273484098.git.marcel@holtmann.org>
 <afefdbc4cf3b9d409d07e1e5264e7ff88bc48711.1273484098.git.marcel@holtmann.org>
 <01760bdde9a92413b7fff928d08e19352bf09d82.1273484098.git.marcel@holtmann.org>
 <44651b85cc3a076147af5d181fc4833ef8debc59.1273484098.git.marcel@holtmann.org>
 <59203a21a56c53afeb6f45e059299e6f1437f30f.1273484098.git.marcel@holtmann.org>
 <0301ef04b5f49a95681694fc0d75af9441faa919.1273484098.git.marcel@holtmann.org>
 <a2e12a2a312f816d5970b0c809d43b399fbfe90c.1273484098.git.marcel@holtmann.org>
 <9b16dc6551cbde65d0ac525af3c46efab53a2c46.1273484098.git.marcel@holtmann.org>
 <ff12fd643334071084b6145cad3793bb6c956638.1273484098.git.marcel@holtmann.org>
 <9a9c6a34416b3743c09c00f3d6708d9df3c21629.1273484098.git.marcel@holtmann.org>
 <f11d676da4059c7888efca810ab300b931736a26.1273484098.git.marcel@holtmann.org>
 <18778a63ddc83bc89bda3b119fb02eb121512a66.1273484098.git.marcel@holtmann.org>
 <9b53350d3cf5b330c3261d89b5e62a2dc25c5653.1273484098.git.marcel@holtmann.org>
 <1890d36bb556a27684ad29654a9898ab9a5f57ee.1273484098.git.marcel@holtmann.org>
 <6161c0382bbab883a634d284f7367a88bbe88534.1273484098.git.marcel@holtmann.org>
 <dfc909befbfe967bd7f46ef33b6969c1b7f3cf42.1273484098.git.marcel@holtmann.org>
 <4178ba462a3e8ab5094e69606f01d9e95f2d5ea6.1273484098.git.marcel@holtmann.org>
 <844c0972427ee5f661158160aaca10b22b3dda60.1273484098.git.marcel@holtmann.org>
 <f48fd9c8cd746fdb055a97249a209c77dca0f710.1273484098.git.marcel@holtmann.org>
 <31f085fea891d5972e994dfb423231a3d4d60a8a.1273484099.git.marcel@holtmann.org>
 <903c843773a18e061817dd7a1a5c28dd41a3bf97.1273484099.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53446 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755950Ab0EJJjR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 10 May 2010 05:39:17 -0400
In-Reply-To: <903c843773a18e061817dd7a1a5c28dd41a3bf97.1273484099.git.marcel@holtmann.org>
In-Reply-To: <cover.1273484094.git.marcel@holtmann.org>
References: <cover.1273484094.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bing Zhao <bzhao@marvell.com>

Move btmrvl hdev registration code out of btmrvl_add_card().
New function btmrvl_register_hdev() is added.

Signed-off-by: Bing Zhao <bzhao@marvell.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 drivers/bluetooth/btmrvl_drv.h  |    1 +
 drivers/bluetooth/btmrvl_main.c |   75 ++++++++++++++++++++++----------------
 drivers/bluetooth/btmrvl_sdio.c |    7 +++-
 3 files changed, 50 insertions(+), 33 deletions(-)

diff --git a/drivers/bluetooth/btmrvl_drv.h b/drivers/bluetooth/btmrvl_drv.h
index da68c62..bf6d54f 100644
--- a/drivers/bluetooth/btmrvl_drv.h
+++ b/drivers/bluetooth/btmrvl_drv.h
@@ -126,6 +126,7 @@ struct btmrvl_event {
 
 /* Prototype of global function */
 
+int btmrvl_register_hdev(struct btmrvl_private *priv);
 struct btmrvl_private *btmrvl_add_card(void *card);
 int btmrvl_remove_card(struct btmrvl_private *priv);
 
diff --git a/drivers/bluetooth/btmrvl_main.c b/drivers/bluetooth/btmrvl_main.c
index 87d0d3d..ec48bfe 100644
--- a/drivers/bluetooth/btmrvl_main.c
+++ b/drivers/bluetooth/btmrvl_main.c
@@ -524,47 +524,20 @@ static int btmrvl_service_main_thread(void *data)
 	return 0;
 }
 
-struct btmrvl_private *btmrvl_add_card(void *card)
+int btmrvl_register_hdev(struct btmrvl_private *priv)
 {
 	struct hci_dev *hdev = NULL;
-	struct btmrvl_private *priv;
 	int ret;
 
-	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
-	if (!priv) {
-		BT_ERR("Can not allocate priv");
-		goto err_priv;
-	}
-
-	priv->adapter = kzalloc(sizeof(*priv->adapter), GFP_KERNEL);
-	if (!priv->adapter) {
-		BT_ERR("Allocate buffer for btmrvl_adapter failed!");
-		goto err_adapter;
-	}
-
-	btmrvl_init_adapter(priv);
-
 	hdev = hci_alloc_dev();
 	if (!hdev) {
 		BT_ERR("Can not allocate HCI device");
 		goto err_hdev;
 	}
 
-	BT_DBG("Starting kthread...");
-	priv->main_thread.priv = priv;
-	spin_lock_init(&priv->driver_lock);
-
-	init_waitqueue_head(&priv->main_thread.wait_q);
-	priv->main_thread.task = kthread_run(btmrvl_service_main_thread,
-				&priv->main_thread, "btmrvl_main_service");
-
 	priv->btmrvl_dev.hcidev = hdev;
-	priv->btmrvl_dev.card = card;
-
 	hdev->driver_data = priv;
 
-	priv->btmrvl_dev.tx_dnld_rdy = true;
-
 	hdev->bus = HCI_SDIO;
 	hdev->open = btmrvl_open;
 	hdev->close = btmrvl_close;
@@ -574,6 +547,8 @@ struct btmrvl_private *btmrvl_add_card(void *card)
 	hdev->ioctl = btmrvl_ioctl;
 	hdev->owner = THIS_MODULE;
 
+	btmrvl_send_module_cfg_cmd(priv, MODULE_BRINGUP_REQ);
+
 	ret = hci_register_dev(hdev);
 	if (ret < 0) {
 		BT_ERR("Can not register HCI device");
@@ -584,16 +559,52 @@ struct btmrvl_private *btmrvl_add_card(void *card)
 	btmrvl_debugfs_init(hdev);
 #endif
 
-	return priv;
+	return 0;
 
 err_hci_register_dev:
-	/* Stop the thread servicing the interrupts */
-	kthread_stop(priv->main_thread.task);
-
 	hci_free_dev(hdev);
 
 err_hdev:
+	/* Stop the thread servicing the interrupts */
+	kthread_stop(priv->main_thread.task);
+
 	btmrvl_free_adapter(priv);
+	kfree(priv);
+
+	return -ENOMEM;
+}
+EXPORT_SYMBOL_GPL(btmrvl_register_hdev);
+
+struct btmrvl_private *btmrvl_add_card(void *card)
+{
+	struct btmrvl_private *priv;
+
+	priv = kzalloc(sizeof(*priv), GFP_KERNEL);
+	if (!priv) {
+		BT_ERR("Can not allocate priv");
+		goto err_priv;
+	}
+
+	priv->adapter = kzalloc(sizeof(*priv->adapter), GFP_KERNEL);
+	if (!priv->adapter) {
+		BT_ERR("Allocate buffer for btmrvl_adapter failed!");
+		goto err_adapter;
+	}
+
+	btmrvl_init_adapter(priv);
+
+	BT_DBG("Starting kthread...");
+	priv->main_thread.priv = priv;
+	spin_lock_init(&priv->driver_lock);
+
+	init_waitqueue_head(&priv->main_thread.wait_q);
+	priv->main_thread.task = kthread_run(btmrvl_service_main_thread,
+				&priv->main_thread, "btmrvl_main_service");
+
+	priv->btmrvl_dev.card = card;
+	priv->btmrvl_dev.tx_dnld_rdy = true;
+
+	return priv;
 
 err_adapter:
 	kfree(priv);
diff --git a/drivers/bluetooth/btmrvl_sdio.c b/drivers/bluetooth/btmrvl_sdio.c
index 0dba76a..df0773e 100644
--- a/drivers/bluetooth/btmrvl_sdio.c
+++ b/drivers/bluetooth/btmrvl_sdio.c
@@ -931,7 +931,12 @@ static int btmrvl_sdio_probe(struct sdio_func *func,
 	priv->hw_host_to_card = btmrvl_sdio_host_to_card;
 	priv->hw_wakeup_firmware = btmrvl_sdio_wakeup_fw;
 
-	btmrvl_send_module_cfg_cmd(priv, MODULE_BRINGUP_REQ);
+	if (btmrvl_register_hdev(priv)) {
+		BT_ERR("Register hdev failed!");
+		ret = -ENODEV;
+		goto disable_host_int;
+	}
+
 	priv->btmrvl_dev.psmode = 1;
 	btmrvl_enable_ps(priv);
 
-- 
1.6.6.1

