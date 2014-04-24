From: Alexander Aring <alex.aring@gmail.com>
Subject: [PATCH net-next 00/14] at86rf230 cleanup
Date: Thu, 24 Apr 2014 19:09:04 +0200
Message-ID: <1398359358-11085-1-git-send-email-alex.aring@gmail.com>
Cc: dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, Alexander Aring <alex.aring@gmail.com>
To: alex.bluesman.smirnov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f53.google.com ([74.125.83.53]:56455 "EHLO
	mail-ee0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758523AbaDXRJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 13:09:36 -0400
Received: by mail-ee0-f53.google.com with SMTP id b57so2071453eek.26
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 10:09:35 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

this is the first patch series to cleanup the at86rf230 driver. Later I want
to implement regmap and a asynchron spi handling for transmit and receiving
frames.

- Alex

Alexander Aring (14):
  at86rf230: use irq_get_trigger_type
  devicetree: add at86rf230 bindings
  at86rf230: remove irq_type in request_irq
  at86rf230: use devm_request_irq
  at86rf230: use devm_gpio_request_one
  at86rf230: add missing MODULE_DEVICE_TABLE
  at86rf230: make of_device_id const
  at86rf230: add at86rf230_device_id table
  at86rf230: remove #ifdef CONFIG_OF
  at86rf230: remove unnecessary assign
  at86rf230: reset irq line before irq request
  at86rf230: remove unnecessary spi_set_drvdata
  at86rf230: remove unnecessary state read
  at86rf230: remove function for setting irq polarity

 .../bindings/net/ieee802154/at86rf230.txt          |  23 ++++
 drivers/net/ieee802154/at86rf230.c                 | 133 +++++++--------------
 include/linux/spi/at86rf230.h                      |  14 ---
 3 files changed, 65 insertions(+), 105 deletions(-)
 create mode 100644 Documentation/devicetree/bindings/net/ieee802154/at86rf230.txt

-- 
1.9.2
