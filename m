From: Finn Thain <fthain@telegraphics.com.au>
Subject: Re: [PATCH 03/15]drivers:staging:rtl8187se:r8180_hw.h Typo change
	diable to disable.
Date: Sat, 1 Jan 2011 17:48:32 +1100 (EST)
Message-ID: <alpine.LNX.2.00.1012311722580.24460@nippy.intranet>
References: <1293750484-1161-1-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-2-git-send-email-justinmattock@gmail.com>
	<1293750484-1161-3-git-send-email-justinmattock@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, trivial@kernel.org, linux-scsi@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	linux-wireless@vger.kernel.org, linux-kernel@vger.kernel.org,
	ivtv-devel@ivtvdriver.org, linux-m68k@lists.linux-m68k.org,
	spi-devel-general@lists.sourceforge.net, linux-media@vger.kernel.org
To: "Justin P. Mattock" <justinmattock@gmail.com>
Return-path: <devel-bounces@linuxdriverproject.org>
In-Reply-To: <1293750484-1161-3-git-send-email-justinmattock@gmail.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/devel>
List-Post: <mailto:devel@linuxdriverproject.org>
List-Help: <mailto:devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/devel>,
	<mailto:devel-request@linuxdriverproject.org?subject=subscribe>
Sender: devel-bounces@linuxdriverproject.org
Errors-To: devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org


On Thu, 30 Dec 2010, Justin P. Mattock wrote:

> The below patch fixes a typo "diable" to "disable". Please let me know if this 
> is correct or not.
> 
> Signed-off-by: Justin P. Mattock <justinmattock@gmail.com>
> 
> ---
>  drivers/staging/rtl8187se/r8180_hw.h |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/drivers/staging/rtl8187se/r8180_hw.h b/drivers/staging/rtl8187se/r8180_hw.h
> index 3fca144..2911d40 100644
> --- a/drivers/staging/rtl8187se/r8180_hw.h
> +++ b/drivers/staging/rtl8187se/r8180_hw.h
> @@ -554,7 +554,7 @@
>  /* by amy for power save		*/
>  /* by amy for antenna			*/
>  #define EEPROM_SW_REVD_OFFSET 0x3f
> -/*  BIT[8-9] is for SW Antenna Diversity. Only the value EEPROM_SW_AD_ENABLE means enable, other values are diable.					*/
> +/*  BIT[8-9] is for SW Antenna Diversity. Only the value EEPROM_SW_AD_ENABLE means enable, other values are disabled.					*/

I think, "other values disable" was what you meant?

Finn

>  #define EEPROM_SW_AD_MASK			0x0300
>  #define EEPROM_SW_AD_ENABLE			0x0100
>  
> 
