From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next 0/3] net: mdio-gpio: Use modern GPIO helpers
Date: Wed, 11 Jan 2017 12:59:48 -0800
Message-ID: <20170111205951.32363-1-f.fainelli@gmail.com>
Cc: davem@davemloft.net, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, cphealy@gmail.com,
        linux@roeck-us.net, Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:32980 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757731AbdAKVAi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 16:00:38 -0500
Received: by mail-pf0-f195.google.com with SMTP id 127so1444pfg.0
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 13:00:37 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

This patch series modernizes the mdio-gpio and makes it switch to the
latest and greatest API for manipulating GPIO lines, thus allowing
some simplifications in the driver.

Thanks!

Guenter Roeck (3):
  net: mdio-gpio: Use devm_gpio_request_one instead of devm_gpio_request
  net: mdio-gpio: Convert to use gpiod functions where possible
  net: mdio-gpio: Use gpio subsystem to handle low-active pins

 drivers/net/phy/mdio-gpio.c | 60 ++++++++++++++++++++++-----------------------
 1 file changed, 30 insertions(+), 30 deletions(-)

-- 
2.9.3
