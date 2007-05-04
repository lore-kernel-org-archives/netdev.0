From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RESEND][PATCH][XFRM] SAD info TLV aggregation
Date: Fri, 04 May 2007 02:19:03 +0200
Message-ID: <463A7BF7.5010604@trash.net>
References: <1178233601.4068.2.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41618 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1423524AbXEDATN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2007 20:19:13 -0400
In-Reply-To: <1178233601.4068.2.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
>  enum xfrm_sadattr_type_t {
> -	XFRMA_SAD_UNSPEC,
> -	XFRMA_SADHMASK,
> -	XFRMA_SADHMAX,
> +	XFRMA_SADUNSPEC,
>  	XFRMA_SADCNT,
> +	XFRMA_SADHINFO,
>  	__XFRMA_SAD_MAX
>  
>  #define XFRMA_SAD_MAX (__XFRMA_SAD_MAX - 1)


I don't want to annoy you unnecessarily, but this still has
the same inconsistent naming (XFRMA_SAD.. vs. XFRMA_SAD_MAX),
just one spot less, which is at least confusing to remember
(as user of an API things like this also tend to make me
suspicious of its quality).

If you dont mind I'm just going to resend myself with fixed
names tomorrow so you don't have to bother doing this again.

