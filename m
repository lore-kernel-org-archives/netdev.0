From: Vadim Kochan <vadim4j@gmail.com>
Subject: Re: [iproute PATCH] ipaddress: Allow listing addresses by type
Date: Thu, 2 Jun 2016 00:50:01 +0300
Message-ID: <20160601215001.GA13978@angus-think.lan>
References: <1464811047-18642-1-git-send-email-phil@nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemming@brocade.com>, netdev@vger.kernel.org,
	Vadim Kochan <vadim4j@gmail.com>
To: Phil Sutter <phil@nwl.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f65.google.com ([209.85.215.65]:33871 "EHLO
	mail-lf0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753074AbcFAV6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jun 2016 17:58:18 -0400
Received: by mail-lf0-f65.google.com with SMTP id 65so3315043lfq.1
        for <netdev@vger.kernel.org>; Wed, 01 Jun 2016 14:58:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1464811047-18642-1-git-send-email-phil@nwl.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 01, 2016 at 09:57:27PM +0200, Phil Sutter wrote:
> Not sure why this was limited to ip-link before. It is semantically
> equal to the 'master' keyword, which is not restricted at all.
> 
Hi Phil,

I don't remember why I did so, but you are right, it might be
used for 'ip addr' too.

> Cc: Vadim Kochan <vadim4j@gmail.com>
> Signed-off-by: Phil Sutter <phil@nwl.cc>
> ---
>  ip/ipaddress.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/ip/ipaddress.c b/ip/ipaddress.c
> index df363b070d5de..1b5ee838ef3fe 100644
> --- a/ip/ipaddress.c
> +++ b/ip/ipaddress.c
> @@ -1613,7 +1613,7 @@ static int ipaddr_list_flush_or_save(int argc, char **argv, int action)
>  			if (!ifindex)
>  				invarg("Device does not exist\n", *argv);
>  			filter.master = ifindex;
> -		} else if (do_link && strcmp(*argv, "type") == 0) {
> +		} else if (strcmp(*argv, "type") == 0) {
>  			NEXT_ARG();
>  			filter.kind = *argv;
>  		} else {
> -- 
> 2.8.2
> 
