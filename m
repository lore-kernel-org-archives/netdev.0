From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] nsh: encapsulation module
Date: Thu, 11 Feb 2016 11:39:46 -0500 (EST)
Message-ID: <20160211.113946.1731145198917250643.davem@davemloft.net>
References: <1455186914-8952-1-git-send-email-brussell@brocade.com>
	<1455186914-8952-3-git-send-email-brussell@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brussell@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:54490 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751083AbcBKQju (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 11:39:50 -0500
In-Reply-To: <1455186914-8952-3-git-send-email-brussell@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Russell <brussell@brocade.com>
Date: Thu, 11 Feb 2016 10:35:13 +0000

> +++ b/include/net/nsh.h
> +struct nsh_metadata {
> +	u_short class;
> +	u_char crit;
> +	u_char type;
> +	u_int len;  /* 4 byte words */
> +	void *data;

Do not use these shorthands, spell out "unsigned short" etc. explicitly.

But in these cases you should be using fixed sized types like "u16".

Also, in a header file such as this one which is private to the kernel
you should be using the variants of these types without the leading underscores.
