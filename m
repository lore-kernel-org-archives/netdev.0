From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [XFRM] Fix unexpected SA hard expiration after
 changing date
Date: Sun, 29 Jul 2012 23:15:07 -0700 (PDT)
Message-ID: <20120729.231507.1019848555665499226.davem@davemloft.net>
References: <1343356759-24767-1-git-send-email-fdu@windriver.com>
	<1343356759-24767-2-git-send-email-fdu@windriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: fdu@windriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50723 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751166Ab2G3GPL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Jul 2012 02:15:11 -0400
In-Reply-To: <1343356759-24767-2-git-send-email-fdu@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fan Du <fdu@windriver.com>
Date: Fri, 27 Jul 2012 10:39:19 +0800

> +				x->curlft.add_time = now - x->saved_tmo - 1;
> +				tmo = x->lft.hard_add_expires_seconds - x->saved_tmo;
> +			
   ^^^^^^^^^^^^^^^^
> +			} else

Unnecessary empty line, please remove it.
