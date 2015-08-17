From: Premkumar Jonnala <pjonnala@broadcom.com>
Subject: RE: [PATCH] iproute2: Extend bridge command to configure ageing
 interval on bridge devices.
Date: Mon, 17 Aug 2015 04:44:26 +0000
Message-ID: <77EF4405DD4BB54AACCE7DB593DF6A9A9E2283@SJEXCHMB14.corp.ad.broadcom.com>
References: <77EF4405DD4BB54AACCE7DB593DF6A9A9E1FA4@SJEXCHMB14.corp.ad.broadcom.com>
 <20150814111155.GC21759@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gw1-out.broadcom.com ([216.31.210.62]:32036 "EHLO
	mail-gw1-out.broadcom.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751326AbbHQEo3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2015 00:44:29 -0400
In-Reply-To: <20150814111155.GC21759@unicorn.suse.cz>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michal,

Thank you for your comments.  I will wait for the review comments on kernel changes, and repost this patch after that.

-Prem

-----Original Message-----
From: Michal Kubecek [mailto:mkubecek@suse.cz] 
Sent: Friday, August 14, 2015 4:42 PM
To: Premkumar Jonnala
Cc: netdev@vger.kernel.org
Subject: Re: [PATCH] iproute2: Extend bridge command to configure ageing interval on bridge devices.

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
