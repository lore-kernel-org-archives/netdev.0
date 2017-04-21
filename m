From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: LAN9303: add I2C dependency
Date: Fri, 21 Apr 2017 15:34:27 -0400 (EDT)
Message-ID: <20170421.153427.1815929300963387314.davem@davemloft.net>
References: <20170421162259.3312997-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, robh@kernel.org, jbe@pengutronix.de,
        sean.wang@mediatek.com, john@phrozen.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37468 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1425283AbdDUTea (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Apr 2017 15:34:30 -0400
In-Reply-To: <20170421162259.3312997-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Fri, 21 Apr 2017 18:22:40 +0200

> With CONFIG_I2C=m and NET_DSA_SMSC_LAN9303=y, we run into a link error:
> 
> drivers/base/regmap/regmap-i2c.o: In function `regmap_smbus_byte_reg_read':
> regmap-i2c.c:(.text.regmap_smbus_byte_reg_read+0x18): undefined reference to `i2c_smbus_read_byte_data'
> drivers/base/regmap/regmap-i2c.o: In function `regmap_smbus_byte_reg_write':
> regmap-i2c.c:(.text.regmap_smbus_byte_reg_write+0x18): undefined reference to `i2c_smbus_write_byte_data'
> drivers/base/regmap/regmap-i2c.o: In function `regmap_smbus_word_reg_read':
> regmap-i2c.c:(.text.regmap_smbus_word_reg_read+0x18): undefined reference to `i2c_smbus_read_word_data'
> drivers/base/regmap/regmap-i2c.o: In function `regmap_smbus_word_read_swapped':
> regmap-i2c.c:(.text.regmap_smbus_word_read_swapped+0x18): undefined reference to `i2c_smbus_read_word_data'
> drivers/base/regmap/regmap-i2c.o: In function `regmap_smbus_word_write_swapped':
> 
> This adds a Kconfig dependency to avoid the broken configuration.
> 
> Fixes: be4e119f9914 ("net: dsa: LAN9303: add I2C managed mode support")
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks.
