From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH net-next 6/7] r8169: add a new chip for RTL8106E
Date: Tue, 2 Apr 2013 00:23:35 +0200
Message-ID: <20130401222335.GC19335@electric-eye.fr.zoreil.com>
References: <1364824539-4156-1-git-send-email-hayeswang@realtek.com>
 <1364824539-4156-6-git-send-email-hayeswang@realtek.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Hayes Wang <hayeswang@realtek.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1364824539-4156-6-git-send-email-hayeswang@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hayes Wang <hayeswang@realtek.com> :
[...]
> - move rtl_set_rx_tx_desc_registers to avoid the tx/rx are enabled
>   before setting desc registers.

This is a wholesale change for the 810x family.

Please explain why issuing rtl_set_rx_tx_desc_registers before writing
ChipCmd is not enough and feed it through a standalone commit.

> Signed-off-by: Hayes Wang <hayeswang@realtek.com>
> ---
>  drivers/net/ethernet/realtek/r8169.c | 25 +++++++++++++++++++++++--
>  1 file changed, 23 insertions(+), 2 deletions(-)
> 
> diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
> index 8d41508..876e088 100644
> --- a/drivers/net/ethernet/realtek/r8169.c
> +++ b/drivers/net/ethernet/realtek/r8169.c
> @@ -49,6 +49,7 @@
>  #define FIRMWARE_8106E_1	"rtl_nic/rtl8106e-1.fw"
>  #define FIRMWARE_8168G_2	"rtl_nic/rtl8168g-2.fw"
>  #define FIRMWARE_8168G_3	"rtl_nic/rtl8168g-3.fw"
> +#define FIRMWARE_8106E_2	"rtl_nic/rtl8106e-2.fw"

I'd rather keep those sorted.

[...]
> @@ -824,6 +829,7 @@ MODULE_FIRMWARE(FIRMWARE_8411_1);
>  MODULE_FIRMWARE(FIRMWARE_8106E_1);
>  MODULE_FIRMWARE(FIRMWARE_8168G_2);
>  MODULE_FIRMWARE(FIRMWARE_8168G_3);
> +MODULE_FIRMWARE(FIRMWARE_8106E_2);

Same thing as above.

-- 
Ueimor
