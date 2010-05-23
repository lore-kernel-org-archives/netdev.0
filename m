From: andrew hendry <andrew.hendry@gmail.com>
Subject: Re: [PATCH 09/12] X25: remove duplicated #include
Date: Sun, 23 May 2010 11:52:06 +1000
Message-ID: <AANLkTikAx8dcmA4VDfOo8IdunMK0sCmMOf3a03KUxxas@mail.gmail.com>
References: <1274548380-188-1-git-send-email-weiyi.huang@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Huang Weiyi <weiyi.huang@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f174.google.com ([209.85.214.174]:60358 "EHLO
	mail-iw0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755970Ab0EWBwJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 May 2010 21:52:09 -0400
Received: by iwn6 with SMTP id 6so2568560iwn.19
        for <netdev@vger.kernel.org>; Sat, 22 May 2010 18:52:08 -0700 (PDT)
In-Reply-To: <1274548380-188-1-git-send-email-weiyi.huang@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

With x25 patches its best to CC netdev, the x25 list is not very active=
=2E
Compile tested, looks fine for net-next.

On Sun, May 23, 2010 at 3:13 AM, Huang Weiyi <weiyi.huang@gmail.com> wr=
ote:
> Remove duplicated #include('s) in
> =A0drivers/net/wan/x25_asy.c
>
> Signed-off-by: Huang Weiyi <weiyi.huang@gmail.com>
> ---
> =A0drivers/net/wan/x25_asy.c | =A0 =A02 --
> =A01 files changed, 0 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/wan/x25_asy.c b/drivers/net/wan/x25_asy.c
> index 166e77d..e47f5a9 100644
> --- a/drivers/net/wan/x25_asy.c
> +++ b/drivers/net/wan/x25_asy.c
> @@ -37,8 +37,6 @@
> =A0#include <net/x25device.h>
> =A0#include "x25_asy.h"
>
> -#include <net/x25device.h>
> -
> =A0static struct net_device **x25_asy_devs;
> =A0static int x25_asy_maxdev =3D SL_NRUNIT;
>
> --
> 1.6.1.3
>
>
