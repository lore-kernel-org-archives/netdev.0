From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH] iproute2: Extend bridge command to configure ageing
 interval on bridge devices.
Date: Fri, 14 Aug 2015 13:11:55 +0200
Message-ID: <20150814111155.GC21759@unicorn.suse.cz>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1FA4@SJEXCHMB14.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Premkumar Jonnala <pjonnala@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.suse.de ([195.135.220.15]:43141 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754009AbbHNLL6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 14 Aug 2015 07:11:58 -0400
Content-Disposition: inline
In-Reply-To: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1FA4@SJEXCHMB14.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 14, 2015 at 09:50:02AM +0000, Premkumar Jonnala wrote:
> Extend bridge command to configure and retrieve ageing interval for bridge
> devices.  Netlink messaging is used to configure and retrieve the ageing
> interval.
> 
> Signed-off-by: Premkumar Jonnala <pjonnala@broadcom.com>
> 
...
> diff --git a/include/linux/rtnetlink.h b/include/linux/rtnetlink.h
> index a78f0b3..abc9617 100644
> --- a/include/linux/rtnetlink.h
> +++ b/include/linux/rtnetlink.h
> @@ -139,6 +139,13 @@ enum {
>  	RTM_GETNSID = 90,
>  #define RTM_GETNSID RTM_GETNSID
>  
> +	RTM_SETAGEING = 92,
> +#define RTM_SETAGEING RTM_SETAGEING
> +	RTM_SETDEFAULTAGEING = 93,
> +#define RTM_SETDEFAULTAGEING RTM_SETDEFAULTAGEING
> +	RTM_GETAGEING = 94,
> +#define RTM_GETAGEING RTM_GETAGEING
> +
>  	__RTM_MAX,
>  #define RTM_MAX		(((__RTM_MAX + 3) & ~3) - 1)
>  };
> --

As far as I can see, this depends on a kernel patch which is still under
review (in particular, adding these new message types was objected to).
I would suggest to wait with submission of the iproute2 patch until
relevant kernel changes are accepted.

                                                          Michal Kubecek
