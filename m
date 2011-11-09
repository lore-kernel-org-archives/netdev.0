From: Joe Perches <joe@perches.com>
Subject: Re: dst->obsolete has become pointless
Date: Wed, 09 Nov 2011 04:49:08 -0800
Message-ID: <1320842948.6923.3.camel@Joe-Laptop>
References: <20111104.230910.520924516201406800.davem@davemloft.net>
	 <20111108093424.GG22141@secunet.com>
	 <20111108.122020.1080743546477280623.davem@davemloft.net>
	 <20111108.135901.1506278599930259562.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: steffen.klassert@secunet.com, netdev@vger.kernel.org,
	timo.teras@iki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:43578 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753982Ab1KIMtJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Nov 2011 07:49:09 -0500
In-Reply-To: <20111108.135901.1506278599930259562.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-11-08 at 13:59 -0500, David Miller wrote:
> net: Kill pointless and misleading checks on dst->obsolete.
[]
> Therefore rename it to dst->freed, and make it take on only the values
> "0" and "1".
> diff --git a/include/net/dst.h b/include/net/dst.h
[]
> @@ -55,7 +55,7 @@ struct dst_entry {
>  #define DST_NOCOUNT		0x0020
>  
>  	short			error;
> -	short			obsolete;
> +	unsigned short		freed;

perhaps
	bool freed;
	bool __pad3;
just to mark the available space a bit more obviously.
