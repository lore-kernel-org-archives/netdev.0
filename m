From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 3/4] r8152: remove clear_bp function
Date: Wed, 20 Aug 2014 16:00:51 +0400
Message-ID: <53F48DF3.8000705@cogentembedded.com>
References: <1394712342-15778-16-Taiwan-albertk@realtek.com> <1394712342-15778-19-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: nic_swsd@realtek.com, linux-kernel@vger.kernel.org,
	linux-usb@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-19-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 8/20/2014 12:58 PM, Hayes Wang wrote:

> The functions are used to update the firmware. Move the actions into
> the firmware files.

> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>   drivers/net/usb/r8152.c | 24 ------------------------
>   1 file changed, 24 deletions(-)

> diff --git a/drivers/net/usb/r8152.c b/drivers/net/usb/r8152.c
> index 33dcc97..937d132 100644
> --- a/drivers/net/usb/r8152.c
> +++ b/drivers/net/usb/r8152.c
[...]
> @@ -2248,7 +2226,6 @@ static void r8152b_hw_phy_cfg(struct r8152 *tp)
>
>   	r8152b_disable_aldps(tp);
>
> -	rtl_clear_bp(tp);
>

    Why leave 2 empty lines? One is enough.

>   	r8152b_enable_aldps(tp);
>   	set_bit(PHY_RESET, &tp->flags);
> @@ -2404,7 +2381,6 @@ static void r8153_hw_phy_cfg(struct r8152 *tp)
>   		r8152_mdio_write(tp, MII_BMCR, data);
>   	}
>
> -	r8153_clear_bp(tp);
>

    Ditto.

>   	if (tp->version == RTL_VER_03) {
>   		data = ocp_reg_read(tp, OCP_EEE_CFG);
>

WBR, Sergei
