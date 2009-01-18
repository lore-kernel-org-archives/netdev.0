From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [PATCH] net: A little dev_valid_name() improvement
Date: Sun, 18 Jan 2009 23:28:46 +0300
Message-ID: <497390FE.4050909@msgid.tls.msk.ru>
References: <8496f91a0901181107o17ee80e7h7fab67194a7bde23@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: matvejchikov@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from hobbit.corpit.ru ([81.13.33.150]:23027 "EHLO hobbit.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753240AbZARU2s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2009 15:28:48 -0500
In-Reply-To: <8496f91a0901181107o17ee80e7h7fab67194a7bde23@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matvejchikov Ilya wrote:
> This patch removes redundant complexity when checking the
> network device name to be valid.

And also disallows any name starting with a dot, while
previously it was allowed/valid.

I don't think this patch is good.

/mjt

> -	if (*name == '\0')
> +	if (*name == '\0' || *name == '.')
>  		return 0;
> -	if (!strcmp(name, ".") || !strcmp(name, ".."))
> -		return 0;

