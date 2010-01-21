From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH] tc: respect LDFLAGS for %.so targets
Date: Thu, 21 Jan 2010 10:05:52 -0800
Message-ID: <20100121100552.734b9c73@nehalam>
References: <1261857156-9037-1-git-send-email-vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: stephen.hemminger@vyatta.com, netdev@vger.kernel.org
To: Mike Frysinger <vapier@gentoo.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:48361 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752538Ab0AUSGT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Jan 2010 13:06:19 -0500
In-Reply-To: <1261857156-9037-1-git-send-email-vapier@gentoo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 26 Dec 2009 14:52:36 -0500
Mike Frysinger <vapier@gentoo.org> wrote:

> Since there aren't any targets that currently use this pattern rule, this
> is more of a proactive fix.
> 
> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
> ---
>  tc/Makefile |    2 +-
>  1 files changed, 1 insertions(+), 1 deletions(-)
> 
> diff --git a/tc/Makefile b/tc/Makefile
> index f3dd2b7..0b5d7d3 100644
> --- a/tc/Makefile
> +++ b/tc/Makefile
> @@ -87,7 +87,7 @@ YACC := bison
>  LEX := flex
>  
>  %.so: %.c
> -	$(CC) $(CFLAGS) -shared -fpic $< -o $@
> +	$(CC) $(CFLAGS) $(LDFLAGS) -shared -fpic $< -o $@
>  
>  
>  all: libtc.a tc $(TCSO)

applied

-- 
