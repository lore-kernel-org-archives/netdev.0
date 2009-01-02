From: Karsten Keil <kkeil@suse.de>
Subject: Re: [PATCH] isdn: capi: &&/|| typos
Date: Fri, 2 Jan 2009 13:16:30 +0100
Message-ID: <20090102121630.GA14957@pingi.kke.suse.de>
References: <495A14AA.2060200@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: kkeil@suse.de, netdev@vger.kernel.org
To: Roel Kluin <roel.kluin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:60587 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751587AbZABMqj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 2 Jan 2009 07:46:39 -0500
Content-Disposition: inline
In-Reply-To: <495A14AA.2060200@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 30, 2008 at 01:31:38PM +0100, Roel Kluin wrote:
> Correct two typos.
> 
> Signed-off-by: Roel Kluin <roel.kluin@gmail.com>

Acked-by: Karsten Keil <kkeil@suse.de>

> ---
> diff --git a/drivers/isdn/capi/capidrv.c b/drivers/isdn/capi/capidrv.c
> index d5b4cc3..6501202 100644
> --- a/drivers/isdn/capi/capidrv.c
> +++ b/drivers/isdn/capi/capidrv.c
> @@ -1519,7 +1519,7 @@ static int decodeFVteln(char *teln, unsigned long *bmaskp, int *activep)
>  		int digit2 = 0;
>  		if (!isdigit(*s)) return -3;
>  		while (isdigit(*s)) { digit1 = digit1*10 + (*s - '0'); s++; }
> -		if (digit1 <= 0 && digit1 > 30) return -4;
> +		if (digit1 <= 0 || digit1 > 30) return -4;
>  		if (*s == 0 || *s == ',' || *s == ' ') {
>  			bmask |= (1 << digit1);
>  			digit1 = 0;
> @@ -1530,7 +1530,7 @@ static int decodeFVteln(char *teln, unsigned long *bmaskp, int *activep)
>  		s++;
>  		if (!isdigit(*s)) return -3;
>  		while (isdigit(*s)) { digit2 = digit2*10 + (*s - '0'); s++; }
> -		if (digit2 <= 0 && digit2 > 30) return -4;
> +		if (digit2 <= 0 || digit2 > 30) return -4;
>  		if (*s == 0 || *s == ',' || *s == ' ') {
>  			if (digit1 > digit2)
>  				for (i = digit2; i <= digit1 ; i++)

-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
