From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 18212] New: force_igmp_version ignored when a IGMPv3
 query received (+1 line patch)
Date: Mon, 13 Sep 2010 12:51:35 -0700 (PDT)
Message-ID: <20100913.125135.48504701.davem@davemloft.net>
References: <20100910091936.75eabbf6@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52740
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755518Ab0IMTvR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Sep 2010 15:51:17 -0400
In-Reply-To: <20100910091936.75eabbf6@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Fri, 10 Sep 2010 09:19:36 -0700

> --- net/ipv4/igmp.c_orig        2010-09-10 08:48:21.390711944 -0700
> +++ net/ipv4/igmp.c     2010-09-10 08:48:45.244218573 -0700
> @@ -834,7 +834,7 @@
>         int                     mark = 0;
> 
> 
> -       if (len == 8) {
> +       if (len == 8 || IGMP_V2_SEEN(in_dev)) {
>                 if (ih->code == 0) {
>                         /* Alas, old v1 router presents here. */
> 
> ---------------------------------

I'll queue this up, thanks.
