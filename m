From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] fec_ptp: Use a more standard logging
Date: Mon, 27 May 2013 23:25:52 -0700 (PDT)
Message-ID: <20130527.232552.1182048690796519978.davem@davemloft.net>
References: <1369681826-5421-1-git-send-email-fabio.estevam@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: fabio.estevam@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933029Ab3E1GZx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 May 2013 02:25:53 -0400
In-Reply-To: <1369681826-5421-1-git-send-email-fabio.estevam@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <fabio.estevam@freescale.com>
Date: Mon, 27 May 2013 16:10:26 -0300

> @@ -17,8 +17,6 @@
>   * 51 Franklin St - Fifth Floor, Boston, MA 02110-1301 USA.
>   */
>  
> -#define pr_fmt(fmt) KBUILD_MODNAME ": " fmt
> -
>  #include <linux/module.h>

I don't see any justification for this part of your change, and at the
very least it's not mentioned nor explained in your commit message.
