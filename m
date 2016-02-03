From: Julian Calaby <julian.calaby@gmail.com>
Subject: Re: [PATCH 1/2] rtlwifi: Fix improve function 'rtl_addr_delay()' in core.c
Date: Wed, 3 Feb 2016 13:07:09 +1100
Message-ID: <CAGRGNgUJGLG_1fWbYLyET-OQeFFxohXqoApcm2E-Jv+W+-FwcQ@mail.gmail.com>
References: <20160203015953.GA13562@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Larry Finger <Larry.Finger@lwfinger.net>,
	Kalle Valo <kvalo@codeaurora.org>,
	Chaoming Li <chaoming_li@realsil.com.cn>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Byeoungwook Kim <quddnr145@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160203015953.GA13562@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Byeounwook,

On Wed, Feb 3, 2016 at 12:59 PM, Byeoungwook Kim <quddnr145@gmail.com> wrote:
> Conditional codes in rtl_addr_delay() were improved in readability and
> performance by using switch codes.
>
> Signed-off-by: Byeoungwook Kim <quddnr145@gmail.com>
> Reported-by: Julian Calaby <julian.calaby@gmail.com>

Reviewed-by: Julian Calaby <julian.calaby@gmail.com>

Thanks,

Julian Calaby


> ---
>  drivers/net/wireless/realtek/rtlwifi/core.c | 20 ++++++++++++++------
>  1 file changed, 14 insertions(+), 6 deletions(-)
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/core.c b/drivers/net/wireless/realtek/rtlwifi/core.c
> index 4ae421e..05f432c 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/core.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/core.c
> @@ -37,18 +37,26 @@
>
>  void rtl_addr_delay(u32 addr)
>  {
> -       if (addr == 0xfe)
> +       switch (addr) {
> +       case 0xfe:
>                 mdelay(50);
> -       else if (addr == 0xfd)
> +               break;
> +       case 0xfd:
>                 mdelay(5);
> -       else if (addr == 0xfc)
> +               break;
> +       case 0xfc:
>                 mdelay(1);
> -       else if (addr == 0xfb)
> +               break;
> +       case 0xfb:
>                 udelay(50);
> -       else if (addr == 0xfa)
> +               break;
> +       case 0xfa:
>                 udelay(5);
> -       else if (addr == 0xf9)
> +               break;
> +       case 0xf9:
>                 udelay(1);
> +               break;
> +       };
>  }
>  EXPORT_SYMBOL(rtl_addr_delay);
>
> --
> 2.5.0
>



-- 
Julian Calaby

Email: julian.calaby@gmail.com
Profile: http://www.google.com/profiles/julian.calaby/
