From: =?ISO-8859-1?Q?J=F6rg-Volker_Peetz?= <jvpeetz@web.de>
Subject: Re: [PATCH 1/4] drivers/net/enic: decrement sizeof size in strncmp
Date: Thu, 12 Nov 2009 11:05:54 +0100
Message-ID: <4AFBDE02.20806@web.de>
References: <Pine.LNX.4.64.0911120848100.16627@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752039AbZKLKH5@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0911120848100.16627@ask.diku.dk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Julia Lawall wrote:
<snip>
> strncmp(foo, abc,=20
> - sizeof(abc)
> + sizeof(abc)-1
>  )
<snip>
> -	if (strncmp(fw_info->hw_version, "A1", sizeof("A1")) =3D=3D 0)
> +	if (strncmp(fw_info->hw_version, "A1", sizeof("A1") - 1) =3D=3D 0)
>  		*hw_ver =3D VNIC_DEV_HW_VER_A1;
> -	else if (strncmp(fw_info->hw_version, "A2", sizeof("A2")) =3D=3D 0)
> +	else if (strncmp(fw_info->hw_version, "A2", sizeof("A2") - 1) =3D=3D=
 0)
<snip>
Why not use strlen(abc) instead of sizeof(abc) - 1 ?
--=20
Regards,
J=F6rg-Volker.
