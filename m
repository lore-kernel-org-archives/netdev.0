From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH 3/3] USB: qmi_wwan: Add ZTE (Vodafone) K3520-Z
Date: Sun, 20 May 2012 12:53:45 +0200
Message-ID: <87y5ongm2u.fsf@nemi.mork.no>
References: <1337502518-1444-1-git-send-email-ajb@spheresystems.co.uk>
	<1337502518-1444-3-git-send-email-ajb@spheresystems.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@linuxfoundation.org, linux-usb@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Andrew Bird <ajb@spheresystems.co.uk>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1337502518-1444-3-git-send-email-ajb@spheresystems.co.uk>
	(Andrew Bird's message of "Sun, 20 May 2012 09:28:38 +0100")
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Andrew Bird <ajb@spheresystems.co.uk> writes:

> Signed-off-by: Andrew Bird <ajb@spheresystems.co.uk>


Acked-by: Bj=C3=B8rn Mork <bjorn@mork.no>

>  /* ZTE suck at making USB descriptors */
> +static const struct driver_info	qmi_wwan_force_int1 =3D {
> +	.description	=3D "Qualcomm WWAN/QMI device",
> +	.flags		=3D FLAG_WWAN,
> +	.bind		=3D qmi_wwan_bind_shared,
> +	.unbind		=3D qmi_wwan_unbind_shared,
> +	.manage_power	=3D qmi_wwan_manage_power,
> +	.data		=3D BIT(1), /* interface whitelist bitmap */
> +};
> +
>  static const struct driver_info	qmi_wwan_force_int4 =3D {
>  	.description	=3D "Qualcomm WWAN/QMI device",
>  	.flags		=3D FLAG_WWAN,
> @@ -430,6 +439,15 @@ static const struct usb_device_id products[] =3D=
 {
>  		.bInterfaceProtocol =3D 0xff,
>  		.driver_info        =3D (unsigned long)&qmi_wwan_force_int4,
>  	},
> +	{	/* ZTE (Vodafone) K3520-Z */
> +		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MA=
TCH_INT_INFO,
> +		.idVendor           =3D 0x19d2,
> +		.idProduct          =3D 0x0055,
> +		.bInterfaceClass    =3D 0xff,
> +		.bInterfaceSubClass =3D 0xff,
> +		.bInterfaceProtocol =3D 0xff,
> +		.driver_info        =3D (unsigned long)&qmi_wwan_force_int1,
> +	},
>  	{	/* ZTE (Vodafone) K3565-Z */
>  		.match_flags	    =3D USB_DEVICE_ID_MATCH_DEVICE | USB_DEVICE_ID_MA=
TCH_INT_INFO,
>  		.idVendor           =3D 0x19d2,


Looking forward to changing all this to a single line device + interfac=
e
number macro in 3.6 :-)


Bj=C3=B8rn
