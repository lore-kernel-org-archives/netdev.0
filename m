From: Karsten Keil <isdn@linux-pingi.de>
Subject: Re: [PATCH] mISDN: Read buffer overflow
Date: Fri, 31 Jul 2009 16:28:04 +0200
Message-ID: <200907311628.05157.isdn@linux-pingi.de>
References: <4A72F51F.3000503@gmail.com>
Reply-To: isdn@linux-pingi.de
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Andreas Eversberg <andreas@eversberg.eu>
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.8]:58088 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751355AbZGaO2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Jul 2009 10:28:16 -0400
In-Reply-To: <4A72F51F.3000503@gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Freitag, 31. Juli 2009 15:43:59 Roel Kluin wrote:

Ouch !
Acked-by: Karsten Keil <keil@b1-systems.de>

> Check whether index is within bounds before testing the element.
>
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>
> ---
> diff --git a/drivers/isdn/mISDN/l1oip_core.c
> b/drivers/isdn/mISDN/l1oip_core.c index c3b661a..7e5f30d 100644
> --- a/drivers/isdn/mISDN/l1oip_core.c
> +++ b/drivers/isdn/mISDN/l1oip_core.c
> @@ -1480,7 +1480,7 @@ l1oip_init(void)
>  		return -ENOMEM;
>
>  	l1oip_cnt = 0;
> -	while (type[l1oip_cnt] && l1oip_cnt < MAX_CARDS) {
> +	while (l1oip_cnt < MAX_CARDS && type[l1oip_cnt]) {
>  		switch (type[l1oip_cnt] & 0xff) {
>  		case 1:
>  			pri = 0;

