From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH] fib_rules: add minimum prefix length
Date: Tue, 23 Jul 2013 15:38:29 -0700
Message-ID: <20130723153829.3b6cb3df@nehalam.linuxnetplumber.net>
References: <20130723220221.GP10216@zirkel.wertarbyte.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Stefan Tomanek <stefan.tomanek@wertarbyte.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f193.google.com ([209.85.192.193]:33574 "EHLO
	mail-pd0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S934783Ab3GWWid (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Jul 2013 18:38:33 -0400
Received: by mail-pd0-f193.google.com with SMTP id w11so416942pde.4
        for <netdev@vger.kernel.org>; Tue, 23 Jul 2013 15:38:32 -0700 (PDT)
In-Reply-To: <20130723220221.GP10216@zirkel.wertarbyte.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 24 Jul 2013 00:02:21 +0200
Stefan Tomanek <stefan.tomanek@wertarbyte.de> wrote:

> diff --git a/include/uapi/linux/fib_rules.h b/include/uapi/linux/fib_rules.h
> index 51da65b..59cd31b 100644
> --- a/include/uapi/linux/fib_rules.h
> +++ b/include/uapi/linux/fib_rules.h
> @@ -45,7 +45,7 @@ enum {
>  	FRA_FLOW,	/* flow/class id */
>  	FRA_UNUSED6,
>  	FRA_UNUSED7,
> -	FRA_UNUSED8,
> +	FRA_TABLE_PREFIXLEN_MIN,
>  	FRA_TABLE,	/* Extended table id */
>  	FRA_FWMASK,	/* mask for netfilter mark */
>  	FRA_OIFNAME,

Not sure if reusing an entry or adding a new value is better
to retain compatibility. Also don't you have to update FRA_GENERIC_POLICY?
