From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/2] dccp: remove unnecessary codes in ipv6.c
Date: Sun, 01 Jul 2012 20:26:43 -0700 (PDT)
Message-ID: <20120701.202643.159397793740641700.davem@davemloft.net>
References: <1341199140-17135-1-git-send-email-roy.qing.li@gmail.com>
	<1341199140-17135-2-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53179 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751032Ab2GBD0o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jul 2012 23:26:44 -0400
In-Reply-To: <1341199140-17135-2-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: roy.qing.li@gmail.com
Date: Mon,  2 Jul 2012 11:19:00 +0800

> -	if (opt != NULL) {
> -		newnp->opt = ipv6_dup_options(newsk, opt);
> -		if (opt != np->opt)
> -			sock_kfree_s(sk, opt, opt->tot_len);
> -	}

Same bug as your other patch, this leaks options.
