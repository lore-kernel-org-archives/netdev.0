From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [Patch] iproute2: clean up genl/genl.c::usage()
Date: Fri, 14 Dec 2012 09:15:37 -0800
Message-ID: <20121214091537.23f22262@nehalam.linuxnetplumber.net>
References: <1355465438-20586-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:41030 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756417Ab2LNRQw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Dec 2012 12:16:52 -0500
In-Reply-To: <1355465438-20586-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 14 Dec 2012 14:10:38 +0800
Cong Wang <amwang@redhat.com> wrote:

> gcc attribute can be used in definition, no need to
> redeclare it.
> 
> Cc: Stephen Hemminger <shemminger@vyatta.com>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/genl/genl.c b/genl/genl.c
> index 49b6596..a1e55e0 100644
> --- a/genl/genl.c
> +++ b/genl/genl.c
> @@ -97,9 +97,7 @@ noexist:
>  	return f;
>  }
>  
> -static void usage(void) __attribute__((noreturn));
> -
> -static void usage(void)
> +static void __attribute__((noreturn)) usage(void)
>  {
>  	fprintf(stderr, "Usage: genl [ OPTIONS ] OBJECT | help }\n"
>  	                "where  OBJECT := { ctrl etc }\n"
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

Why bother, all the other older code uses the prototype version,
besides the optimizing of usage() function is ridiculous anyway.
I am just going to remove all the 
  static void usage(void) __attribute__((noreturn));
