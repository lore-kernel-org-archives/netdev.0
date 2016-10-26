From: Jakub Sitnicki <jkbs@redhat.com>
Subject: Re: [PATCH] rtl8xxxu: mark symbol static where possible
Date: Wed, 26 Oct 2016 14:37:15 +0200
Message-ID: <87twbz2sn8.fsf@redhat.com>
References: <1477474370-31383-1-git-send-email-baoyou.xie@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, arnd@arndb.de, xie.baoyou@zte.com.cn,
        han.fei@zte.com.cn, tang.qiang007@zte.com.cn
To: Baoyou Xie <baoyou.xie@linaro.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-reply-to: <1477474370-31383-1-git-send-email-baoyou.xie@linaro.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 26, 2016 at 09:32 AM GMT, Baoyou Xie wrote:
> We get 1 warning when building kernel with W=1:
> drivers/net/wireless/realtek/rtl8xxxu/rtl8xxxu_8192e.c:1557:6: warning: no previous prototype for 'rtl8192eu_power_off' [-Wmissing-prototypes]
>
> In fact, this function is only used in the file in which it is
> declared and don't need a declaration, but can be made static.
> So this patch marks this function with 'static'.
>
> Signed-off-by: Baoyou Xie <baoyou.xie@linaro.org>
> ---
>  drivers/net/dsa/mv88e6xxx/chip.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/dsa/mv88e6xxx/chip.c b/drivers/net/dsa/mv88e6xxx/chip.c
> index 883fd98..4d975f0 100644
> --- a/drivers/net/dsa/mv88e6xxx/chip.c
> +++ b/drivers/net/dsa/mv88e6xxx/chip.c
> @@ -2701,7 +2701,7 @@ static int mv88e6xxx_setup_port(struct mv88e6xxx_chip *chip, int port)
>  	return mv88e6xxx_port_write(chip, port, PORT_DEFAULT_VLAN, 0x0000);
>  }
>  
> -int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
> +static int mv88e6xxx_g1_set_switch_mac(struct mv88e6xxx_chip *chip, u8 *addr)
>  {
>  	int err;

Probably a mix-up - your patch doesn't match the description.

Thanks,
Jakub
