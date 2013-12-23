From: RongQing Li <roy.qing.li@gmail.com>
Subject: Re: [PATCH] ipv6: unneccessary to get address prefix in addrconf_get_prefix_route
Date: Mon, 23 Dec 2013 09:49:40 +0800
Message-ID: <CAJFZqHzFNRE-VvB6D-eLZKru40dbRgA_vkpL44+eTEPYDggCGw@mail.gmail.com>
References: <1387762358-10607-1-git-send-email-roy.qing.li@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f174.google.com ([209.85.128.174]:49626 "EHLO
	mail-ve0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756515Ab3LWBtl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Dec 2013 20:49:41 -0500
Received: by mail-ve0-f174.google.com with SMTP id pa12so2564709veb.19
        for <netdev@vger.kernel.org>; Sun, 22 Dec 2013 17:49:40 -0800 (PST)
In-Reply-To: <1387762358-10607-1-git-send-email-roy.qing.li@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 23, 2013 at 9:32 AM,  <roy.qing.li@gmail.com> wrote:
> From: Li RongQing <roy.qing.li@gmail.com>
>
> Since addrconf_get_prefix_route inputs the address prefix to fib6_locate,
> which does not uses the data which is out of the prefix_len length,
> so do not need to use ipv6_addr_prefix to get address prefix.
>
> Signed-off-by: Li RongQing <roy.qing.li@gmail.com>
> ---
>  net/ipv6/addrconf.c |    5 +----
>  1 file changed, 1 insertion(+), 4 deletions(-)
>

This should be for net-next, sorry.
Thanks
