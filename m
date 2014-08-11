From: Paul Moore <paul@paul-moore.com>
Subject: Re: [PATCH net-next] netlabel: add missing inline to stub
Date: Mon, 11 Aug 2014 11:27:15 -0400
Message-ID: <1516624.TGbEHg5hL8@sifl>
References: <20140811082235.15c800ae@haswell.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f174.google.com ([209.85.216.174]:53688 "EHLO
	mail-qc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753660AbaHKP1T (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Aug 2014 11:27:19 -0400
Received: by mail-qc0-f174.google.com with SMTP id l6so1698104qcy.19
        for <netdev@vger.kernel.org>; Mon, 11 Aug 2014 08:27:18 -0700 (PDT)
In-Reply-To: <20140811082235.15c800ae@haswell.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, August 11, 2014 08:22:35 AM Stephen Hemminger wrote:
> This stub like all the nearby stubs should be inline.
> This fixes a sparse warning about defined but never used.
> 
> Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>

FYI, the same patch was sent to Linus last week.

> --- a/include/net/netlabel.h	2014-08-09 08:39:57.704179307 -0700
> +++ b/include/net/netlabel.h	2014-08-11 07:54:01.058097452 -0700
> @@ -524,10 +524,10 @@ static inline int netlbl_catmap_setrng(s
>  {
>  	return 0;
>  }
> -static int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
> -				 u32 offset,
> -				 unsigned long bitmap,
> -				 gfp_t flags)
> +static inline int netlbl_catmap_setlong(struct netlbl_lsm_catmap **catmap,
> +					u32 offset,
> +					unsigned long bitmap,
> +					gfp_t flags)
>  {
>  	return 0;
>  }

-- 
paul moore
www.paul-moore.com
