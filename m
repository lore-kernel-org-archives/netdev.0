From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [PATCH] niu: Rename NIU parent platform device name to fix conflict.
Date: Sun, 20 Mar 2011 00:27:48 -0600
Message-ID: <AANLkTimzGTe52by8d4NQPV1f8Wmayb6ZoNMX4yDqFCFD@mail.gmail.com>
References: <20110319.230733.193709340.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gx0-f174.google.com ([209.85.161.174]:62908 "EHLO
	mail-gx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751151Ab1CTG2I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Mar 2011 02:28:08 -0400
Received: by gxk21 with SMTP id 21so2047131gxk.19
        for <netdev@vger.kernel.org>; Sat, 19 Mar 2011 23:28:08 -0700 (PDT)
In-Reply-To: <20110319.230733.193709340.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 20, 2011 at 12:07 AM, David Miller <davem@davemloft.net> wr=
ote:
>
> When the OF device driver bits were converted over to the platform
> device infrastructure in commit 74888760d40b3ac9054f9c5fa07b566c0676b=
a2d
> ("dt/net: Eliminate users of of_platform_{,un}register_driver") we
> inadvertantly created probing problems in the OF case.
[...]
>
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>
> Grant, I'll push this fix via the net-2.6 tree, you don't have
> to worry about it.

Okay, thanks.

g.

>
> =A0drivers/net/niu.c | =A0 =A02 +-
> =A01 files changed, 1 insertions(+), 1 deletions(-)
>
> diff --git a/drivers/net/niu.c b/drivers/net/niu.c
> index 40fa59e..32678b6 100644
> --- a/drivers/net/niu.c
> +++ b/drivers/net/niu.c
> @@ -9501,7 +9501,7 @@ static struct niu_parent * __devinit niu_new_pa=
rent(struct niu *np,
> =A0 =A0 =A0 =A0struct niu_parent *p;
> =A0 =A0 =A0 =A0int i;
>
> - =A0 =A0 =A0 plat_dev =3D platform_device_register_simple("niu", niu=
_parent_index,
> + =A0 =A0 =A0 plat_dev =3D platform_device_register_simple("niu-board=
", niu_parent_index,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 NULL, 0);
> =A0 =A0 =A0 =A0if (IS_ERR(plat_dev))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NULL;
> --
> 1.7.4.1
>
>



--=20
Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
