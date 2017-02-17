From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: Re: [PATCH trivial 2/4] rtlwifi: rtl8821ae: Spelling
 s/wrtie_addr/write_addr/
Date: Fri, 17 Feb 2017 10:14:44 -0600
Message-ID: <2c7a3011-3418-35a5-ca2e-88c0188baccf@lwfinger.net>
References: <1487345799-1638-1-git-send-email-geert+renesas@glider.be>
 <1487345799-1638-2-git-send-email-geert+renesas@glider.be>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        Chaoming Li <chaoming_li@realsil.com.cn>,
        netdev@vger.kernel.org
To: Geert Uytterhoeven <geert+renesas@glider.be>,
        Jiri Kosina <trivial@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1487345799-1638-2-git-send-email-geert+renesas@glider.be>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/17/2017 09:36 AM, Geert Uytterhoeven wrote:
> As per symmetry with _rtl8821ae_dbi_read(), "wrtie" is not a funky
> register acronym, but a simple misspelling of "write".
>
> Signed-off-by: Geert Uytterhoeven <geert+renesas@glider.be>
> Cc: Larry Finger <Larry.Finger@lwfinger.net>
> Cc: Chaoming Li <chaoming_li@realsil.com.cn>
> Cc: netdev@vger.kernel.org

I'm not sure that it is possible to have a typo in a variable name. That seems 
to be within an author's prerogative. Nonetheless, the patch is OK other than it 
was sent to the wrong destination. Patches for this driver should go through 
linux-wireless@vger.kernel.org. Kalle Valo is the wireless maintainer, but it is 
not necessary to send to him directly as he usually picks up the patches from 
Patchwork.

Larry

> ---
>  drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c | 10 +++++-----
>  1 file changed, 5 insertions(+), 5 deletions(-)
>
> diff --git a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
> index 4f83eee1ff75bc81..546f085afb8f42fa 100644
> --- a/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
> +++ b/drivers/net/wireless/realtek/rtlwifi/rtl8821ae/hw.c
> @@ -1135,13 +1135,13 @@ static u8 _rtl8821ae_dbi_read(struct rtl_priv *rtlpriv, u16 addr)
>  static void _rtl8821ae_dbi_write(struct rtl_priv *rtlpriv, u16 addr, u8 data)
>  {
>  	u8 tmp = 0, count = 0;
> -	u16 wrtie_addr, remainder = addr % 4;
> +	u16 write_addr, remainder = addr % 4;
>
> -	wrtie_addr = REG_DBI_WDATA + remainder;
> -	rtl_write_byte(rtlpriv, wrtie_addr, data);
> +	write_addr = REG_DBI_WDATA + remainder;
> +	rtl_write_byte(rtlpriv, write_addr, data);
>
> -	wrtie_addr = (addr & 0xfffc) | (BIT(0) << (remainder + 12));
> -	rtl_write_word(rtlpriv, REG_DBI_ADDR, wrtie_addr);
> +	write_addr = (addr & 0xfffc) | (BIT(0) << (remainder + 12));
> +	rtl_write_word(rtlpriv, REG_DBI_ADDR, write_addr);
>
>  	rtl_write_byte(rtlpriv, REG_DBI_FLAG, 0x1);
>
>
