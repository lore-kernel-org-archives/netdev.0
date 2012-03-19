From: Randy Dunlap <rdunlap@xenotime.net>
Subject: Re: [PATCH] net: qmi_wwan: fix build error due to cdc-wdm dependecy
Date: Mon, 19 Mar 2012 13:16:55 -0700
Message-ID: <4F679437.8030201@xenotime.net>
References: <20120319184830.fce597a16eaf7206195a7a45@canb.auug.org.au> <1332179309-4163-1-git-send-email-bjorn@mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org,
	Greg KH <gregkh@linuxfoundation.org>
To: =?UTF-8?B?QmrDuHJuIE1vcms=?= <bjorn@mork.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1332179309-4163-1-git-send-email-bjorn@mork.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/19/2012 10:48 AM, Bj=C3=B8rn Mork wrote:

> Fixes:
>=20
> drivers/built-in.o: In function `qmi_wwan_bind_shared':
> qmi_wwan.c:(.text+0x25b686): undefined reference to `usb_cdc_wdm_regi=
ster'
> make[1]: *** [.tmp_vmlinux1] Error 1
>=20
> Reported-by: Randy Dunlap <rdunlap@xenotime.net>
> Signed-off-by: Bj=C3=B8rn Mork <bjorn@mork.no>


Acked-by: Randy Dunlap <rdunlap@xenotime.net>

Thanks.


> ---
> Thanks for noticing.
>=20
> This should have been in commit c3ecb08a
>  net: qmi_wwan: support devices having a shared QMI/wwan interface
>=20
>=20
> Bj=C3=B8rn
>=20
>=20
>  drivers/net/usb/Kconfig |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
>=20
> diff --git a/drivers/net/usb/Kconfig b/drivers/net/usb/Kconfig
> index 4bad899..833e32f 100644
> --- a/drivers/net/usb/Kconfig
> +++ b/drivers/net/usb/Kconfig
> @@ -401,6 +401,7 @@ config USB_NET_KALMIA
>  config USB_NET_QMI_WWAN
>  	tristate "QMI WWAN driver for Qualcomm MSM based 3G and LTE modems"
>  	depends on USB_USBNET
> +	select USB_WDM
>  	help
>  	  Support WWAN LTE/3G devices based on Qualcomm Mobile Data Modem
>  	  (MDM) chipsets.  Examples of such devices are



--=20
~Randy
