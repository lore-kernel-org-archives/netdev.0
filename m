From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: [PATCH] staging: r8188eu: Fix typo in USB_DEVICE list
Date: Mon, 3 Feb 2014 12:17:38 +0300
Message-ID: <20140203091738.GC26722@mwanda>
References: <1391371626-13551-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, gregkh@linuxfoundation.org,
 netdev@vger.kernel.org
To: Larry Finger <Larry.Finger@lwfinger.net>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
Content-Disposition: inline
In-Reply-To: <1391371626-13551-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

On Sun, Feb 02, 2014 at 02:07:06PM -0600, Larry Finger wrote:
> There is a typo in the device list that interchanges the vendor and
> product codes for one of the entries.
> 
> Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
> ---
>  drivers/staging/rtl8188eu/os_dep/usb_intf.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/drivers/staging/rtl8188eu/os_dep/usb_intf.c b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
> index 0a341d6..e9e3c76 100644
> --- a/drivers/staging/rtl8188eu/os_dep/usb_intf.c
> +++ b/drivers/staging/rtl8188eu/os_dep/usb_intf.c
> @@ -53,7 +53,7 @@ static struct usb_device_id rtw_usb_id_tbl[] = {
>  	{USB_DEVICE(USB_VENDER_ID_REALTEK, 0x0179)}, /* 8188ETV */
>  	/*=== Customer ID ===*/
>  	/****** 8188EUS ********/
> -	{USB_DEVICE(0x8179, 0x07B8)}, /* Abocom - Abocom */
> +	{USB_DEVICE(0x07bb, 0x8179)}, /* Abocom - Abocom */
                    ^^^^^^
Should this be      0x07b8?

regards,
dan carpenter

>  	{USB_DEVICE(0x2001, 0x330F)}, /* DLink DWA-125 REV D1 */
>  	{}	/* Terminating entry */
>  };
> -- 
> 1.8.4
> 
> _______________________________________________
> devel mailing list
> devel@linuxdriverproject.org
> http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel
