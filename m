From: Alexey Dobriyan <adobriyan@gmail.com>
Subject: Re: [PATCH 2.6.20] ixgb: Use ARRAY_SIZE macro when appropriate
Date: Mon, 5 Feb 2007 23:18:04 +0300
Message-ID: <20070205201804.GC11055@martell.zuzino.mipt.ru>
References: <20070205165429.GD3896@Ahmed> <20070205165933.GL3896@Ahmed>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: jeffrey.t.kirsher@intel.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: "Ahmed S. Darwish" <darwish.07@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ug-out-1314.google.com ([66.249.92.170]:53736 "EHLO
	ug-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933225AbXBEUSG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Feb 2007 15:18:06 -0500
Received: by ug-out-1314.google.com with SMTP id 44so1403857uga
        for <netdev@vger.kernel.org>; Mon, 05 Feb 2007 12:18:04 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20070205165933.GL3896@Ahmed>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 05, 2007 at 06:59:33PM +0200, Ahmed S. Darwish wrote:
> A patch to use ARRAY_SIZE macro already defined in kernel.h.

Remove it and use ARRAY_SIZE instead.

> --- a/drivers/net/ixgb/ixgb_param.c
> +++ b/drivers/net/ixgb/ixgb_param.c
> @@ -245,7 +245,7 @@ ixgb_validate_option(int *value, struct ixgb_option *opt)
>  	return -1;
>  }
>  
> -#define LIST_LEN(l) (sizeof(l) / sizeof(l[0]))
> +#define LIST_LEN(l) ARRAY_SIZE(l)

