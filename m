From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] net: wan: slic_ds26522: add SPI device ID table to
 fix module autoload
Date: Fri, 14 Oct 2016 10:12:37 -0400 (EDT)
Message-ID: <20161014.101237.1082985188375412438.davem@davemloft.net>
References: <1476298541-7354-1-git-send-email-javier@osg.samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        qiang.zhao@nxp.com
To: javier@osg.samsung.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1476298541-7354-1-git-send-email-javier@osg.samsung.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Javier Martinez Canillas <javier@osg.samsung.com>
Date: Wed, 12 Oct 2016 15:55:40 -0300

> If the driver is built as a module, module alias information isn't filled
> so the module won't be autoloaded. Add a SPI device ID table and use the
> MODULE_DEVICE_TABLE() macro so the information is exported in the module.
> 
> Before this patch:
> 
> $ modinfo drivers/net/wan/slic_ds26522.ko | grep alias
> $
> 
> After this patch:
> 
> $ modinfo drivers/net/wan/slic_ds26522.ko | grep alias
> alias:          spi:ds26522
> 
> Signed-off-by: Javier Martinez Canillas <javier@osg.samsung.com>

Applied.
