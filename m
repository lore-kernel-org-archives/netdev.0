From: "Richard B. Johnson" <root@chaos.analogic.com>
Subject: Re: [patch 2.6.9 9/11] r8169: Add MODULE_VERSION
Date: Wed, 20 Oct 2004 16:34:45 -0400 (EDT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410201629120.6918@chaos.analogic.com>
References: <20041020141146.C8775@tuxdriver.com> <20041020142858.L8775@tuxdriver.com>
Reply-To: root@chaos.analogic.com
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@oss.sgi.com, Linux kernel <linux-kernel@vger.kernel.org>,
        jgarzik@pobox.com, romieu@fr.zoreil.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "John W. Linville" <linville@tuxdriver.com>
In-Reply-To: <20041020142858.L8775@tuxdriver.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


This makes warning error about :

Warning: could not find versions for .tmp_versions/r8169.mod

Do I have to enable something in .config (like CONFIG_MODVERSIONS)?
If so, how does one make this transparent, to get rid of the
warning if CONFIG_MODVERSIONS is not set?


On Wed, 20 Oct 2004, John W. Linville wrote:

> Add MODULE_VERSION to r8169 driver.
>
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
>
> drivers/net/r8169.c |    1 +
> 1 files changed, 1 insertion(+)
>
> --- linux-2.6.9/drivers/net/r8169.c.orig
> +++ linux-2.6.9/drivers/net/r8169.c
> @@ -362,6 +362,7 @@ MODULE_PARM(rx_copybreak, "i");
> MODULE_PARM(use_dac, "i");
> MODULE_PARM_DESC(use_dac, "Enable PCI DAC. Unsafe on 32 bit PCI slot.");
> MODULE_LICENSE("GPL");
> +MODULE_VERSION(RTL8169_VERSION);
>
> static int rtl8169_open(struct net_device *dev);
> static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev);
> -
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/
>

Cheers,
Dick Johnson
Penguin : Linux version 2.6.9 on an i686 machine (5537.79 GrumpyMips).
                  98.36% of all statistics are fiction.
