From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] reduce stack usage for arlan
Date: Sun, 15 May 2005 23:22:35 -0400
Message-ID: <428811FB.1050308@pobox.com>
References: <20050308153457.GB8703@wohnheim.fh-wedel.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: =?ISO-8859-1?Q?J=F6rn_Engel?= <joern@wohnheim.fh-wedel.de>
In-Reply-To: <20050308153457.GB8703@wohnheim.fh-wedel.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

J=F6rn Engel wrote:
> Jean Tourrilhes indicated that this driver is currently unmaintained.
> Jeff, do you want this patch?

>  #define SARLSTR(var,nn) {\
> -	char tmpStr[400];\
> +	char tmpStr[50];\
>  	int  tmpLn =3D nn;\
> -	if (nn > 399 ) tmpLn =3D 399; \
> +	BUG_ON(tmpLn > 49);\


I'm uncomfortable with arbitrarily lowering the string size, even if it=20
does include a BUG_ON()...

	Jeff
