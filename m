From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [RFC PATCH 1/5] geneve: remove MODULE_ALIAS_RTNL_LINK from
 net/ipv4/geneve.c
Date: Thu, 2 Apr 2015 16:39:19 -0700
Message-ID: <20150402163919.7b07039a@urahara>
References: <1428002227-11636-1-git-send-email-linville@tuxdriver.com>
	<1428002227-11636-2-git-send-email-linville@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Jesse Gross <jesse@nicira.com>, Andy Zhou <azhou@nicira.com>,
	Alexander Duyck <alexander.h.duyck@redhat.com>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:34106 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751295AbbDBXjP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 19:39:15 -0400
Received: by pactp5 with SMTP id tp5so98414514pac.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 16:39:15 -0700 (PDT)
In-Reply-To: <1428002227-11636-2-git-send-email-linville@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  2 Apr 2015 15:17:02 -0400
"John W. Linville" <linville@tuxdriver.com> wrote:

> This file is essentially a library for implementing the geneve
> encapsulation protocol.  The file does not register any rtnl_link_ops,
> so the MODULE_ALIAS_RTNL_LINK macro is inappropriate here.
> 
> Signed-off-by: John W. Linville <linville@tuxdriver.com>
> ---
>  net/ipv4/geneve.c | 1 -
>  1 file changed, 1 deletion(-)
> 
> diff --git a/net/ipv4/geneve.c b/net/ipv4/geneve.c
> index 5a4828ba05ad..ba5283adbee8 100644
> --- a/net/ipv4/geneve.c
> +++ b/net/ipv4/geneve.c
> @@ -450,4 +450,3 @@ module_exit(geneve_cleanup_module);
>  MODULE_LICENSE("GPL");
>  MODULE_AUTHOR("Jesse Gross <jesse@nicira.com>");
>  MODULE_DESCRIPTION("Driver for GENEVE encapsulated traffic");
> -MODULE_ALIAS_RTNL_LINK("geneve");

ok but then how does it get autoloaded?
