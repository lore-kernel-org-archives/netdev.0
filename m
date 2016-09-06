From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lan78xx: mark symbols static where possible
Date: Tue, 06 Sep 2016 15:59:49 -0700 (PDT)
Message-ID: <20160906.155949.480171381998479160.davem@davemloft.net>
References: <1473149942-26130-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: woojung.huh@microchip.com, UNGLinuxDriver@microchip.com,
        netdev@vger.kernel.org, linux-usb@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn
To: baoyou.xie@linaro.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1473149942-26130-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baoyou Xie <baoyou.xie@linaro.org>
Date: Tue,  6 Sep 2016 16:19:02 +0800

> We get a few warnings when building kernel with W=1:
> drivers/net/usb/lan78xx.c:1182:6: warning: no previous prototype for 'lan78xx_defer_kevent' [-Wmissing-prototypes]
> drivers/net/usb/lan78xx.c:1409:5: warning: no previous prototype for 'lan78xx_nway_reset' [-Wmissing-prototypes]
> drivers/net/usb/lan78xx.c:2000:5: warning: no previous prototype for 'lan78xx_set_mac_addr' [-Wmissing-prototypes]
> ....
> 
> In fact, these functions are only used in the file in which they are
> declared and don't need a declaration, but can be made static.
> so this patch marks these functions with 'static'.
> 
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>

Applied.
