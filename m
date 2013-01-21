From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/5 v2] soreuseport: infrastructure
Date: Sun, 20 Jan 2013 23:06:42 -0500 (EST)
Message-ID: <20130120.230642.705097270069078563.davem@davemloft.net>
References: <alpine.DEB.2.00.1301201542520.924@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netdev@markandruth.co.uk,
	eric.dumazet@gmail.com
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:33483 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752617Ab3AUEGo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 20 Jan 2013 23:06:44 -0500
In-Reply-To: <alpine.DEB.2.00.1301201542520.924@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Sun, 20 Jan 2013 16:07:22 -0800 (PST)

> diff --git a/include/uapi/asm-generic/socket.h b/include/uapi/asm-generic/socket.h
> index 3f6a992..4ef3acb 100644
> --- a/include/uapi/asm-generic/socket.h
> +++ b/include/uapi/asm-generic/socket.h
> @@ -22,8 +22,7 @@
>  #define SO_PRIORITY	12
>  #define SO_LINGER	13
>  #define SO_BSDCOMPAT	14
> -/* To add :#define SO_REUSEPORT 15 */
> -
> +#define SO_REUSEPORT	15
>  #ifndef SO_PASSCRED /* powerpc only differs in these */
>  #define SO_PASSCRED	16
>  #define SO_PEERCRED	17

A new value needs to be added for every architecture, rather than just
the ones that happen to use this asm-generic/socket.h file.
