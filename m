From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: pxa168_etc.c recognize additional contributors
Date: Thu, 30 Sep 2010 17:33:15 -0700 (PDT)
Message-ID: <20100930.173315.173856658.davem@davemloft.net>
References: <73276AFF-CD7C-4D61-AD6B-E0EC48C5D30C@marvell.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, markb@marvell.com, ssanap@marvell.com
To: prakity@marvell.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33596
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755106Ab0JAAcy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Sep 2010 20:32:54 -0400
In-Reply-To: <73276AFF-CD7C-4D61-AD6B-E0EC48C5D30C@marvell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Philip Rakity <prakity@marvell.com>
Date: Tue, 28 Sep 2010 07:26:30 -0700

> Signed-off-by: Philip Rakity <prakity@marvell.com>
> Signed-off-by: Sachin Sanap <ssanap@marvell.com>
> Signed-off-by: Mark Brown <markb@marvell.com>

Your patch is corrupted, did you try to edit it by hand
in something like emacs?

> diff --git a/drivers/net/pxa168_eth.c b/drivers/net/pxa168_eth.c
> index c6eeb38..0f2d41b 100644
> --- a/drivers/net/pxa168_eth.c
> +++ b/drivers/net/pxa168_eth.c
> @@ -4,8 +4,10 @@

This hunk header says there are 8 lines in the hunk beforehand
and 10 lines afterwards.

>   *
>   * Copyright (C) 2010 Marvell International Ltd.
>   *		Sachin Sanap <ssanap@marvell.com>
> + *		Zhangfei Gao <zgao6@marvell.com>
>   *		Philip Rakity <prakity@marvell.com>
>   *		Mark Brown <markb@marvell.com>
>   *
>   * This program is free software; you can redistribute it and/or
>   * modify it under the terms of the GNU General Public License
> -- 
> 1.6.0.4

But clearly there are 8 beforehand and 9 afterwards.

Anyways I fixed this up and added your change, but please be
more careful in the future.
