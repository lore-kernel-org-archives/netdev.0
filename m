From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [net-next-2.6] XFRM: remove unused member in xfrm_encap_tmpl.
Date: Mon, 29 Nov 2010 20:07:46 +0200
Message-ID: <4CF3EBF2.5060308@iki.fi>
References: <AANLkTiknTcWaRykGOTbw6JpFZN-ePnRXd3iWz86yYHKi@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: David Shwatrz <dshwatrz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f46.google.com ([209.85.215.46]:52304 "EHLO
	mail-ew0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751203Ab0K2SHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 13:07:54 -0500
Received: by ewy5 with SMTP id 5so2156045ewy.19
        for <netdev@vger.kernel.org>; Mon, 29 Nov 2010 10:07:52 -0800 (PST)
In-Reply-To: <AANLkTiknTcWaRykGOTbw6JpFZN-ePnRXd3iWz86yYHKi@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/-10/-28163 09:59 PM, David Shwatrz wrote:
> Hi,
>  The patch removes unused member in xfrm_encap_tmpl.
> 
> Regards,
> David Shwartz
> 
> 
> Signed-off-by: David Shwartz <dshwatrz@gmail.com>
> 
> 
> diff --git a/include/linux/xfrm.h b/include/linux/xfrm.h
> index b971e38..7312707 100644
> --- a/include/linux/xfrm.h
> +++ b/include/linux/xfrm.h
> @@ -235,7 +235,6 @@ struct xfrm_encap_tmpl {
>  	__u16		encap_type;
>  	__be16		encap_sport;
>  	__be16		encap_dport;
> -	xfrm_address_t	encap_oa;
>  };
>  
>  /* AEVENT flags  */

struct xfrm_encap_tmpl is exposed to userland via netlink. This would
break ABI.
