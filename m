From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2.6.20] wavelan: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 23:17:09 +0300
Message-ID: <20070205201709.GB11055@martell.zuzino.mipt.ru>
References: <20070205165429.GD3896@Ahmed> <20070205170044.GM3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jt@hpl.hp.com, linville@tuxdriver.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.171]:53031 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933214AbXBEURM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 15:17:12 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1403621uga
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 12:17:11 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20070205170044.GM3896@Ahmed>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 07:00:44PM +0200, Ahmed S. Darwish wrote:
> A trivial patch to use ARRAY_SIZE macro.

You're supposed to remove it ans use ARRAY_SIZE where old macro is used.

> --- a/drivers/net/wireless/wavelan.p.h
> +++ b/drivers/net/wireless/wavelan.p.h
> @@ -450,7 +450,7 @@ static const char	*version	= "wavelan.c : v24 (SMP + wireless extensions) 11/12/
>  #define	WATCHDOG_JIFFIES	(512*HZ/100)
>
>  /* Macro to get the number of elements in an array */
> -#define	NELS(a)				(sizeof(a) / sizeof(a[0]))
> +#define	NELS(a)				ARRAY_SIZE(a)

