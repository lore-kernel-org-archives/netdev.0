From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH][XFRM] SAD info TLV aggregation
Date: Thu, 03 May 2007 02:15:10 +0200
Message-ID: <4639298E.8090100@trash.net>
References: <1178144288.4078.5.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:48349 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1767282AbXECAPr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2007 20:15:47 -0400
In-Reply-To: <1178144288.4078.5.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> I am keeping the thin 32 bit header, but other than that everything is
> in one TLV. SPD info one to follow..


I think using attributes here wasn't a bad idea since this exports
things that are implementation details and might need to be changed
or extended at some point.

>  enum xfrm_sadattr_type_t {
>  	XFRMA_SAD_UNSPEC,
> -	XFRMA_SADHMASK,
> -	XFRMA_SADHMAX,
> -	XFRMA_SADCNT,
> +	XFRMA_SADINFO,
>  	__XFRMA_SAD_MAX
>  
>  #define XFRMA_SAD_MAX (__XFRMA_SAD_MAX - 1)
>  };

In any case consistent naming here would be nice (SAD_ vs. SADXXX).
