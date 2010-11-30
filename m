From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3] inetpeer: Support ipv6 addresses.
Date: Mon, 29 Nov 2010 19:18:46 -0800 (PST)
Message-ID: <20101129.191846.71126590.davem@davemloft.net>
References: <20101129.134403.179947389.davem@davemloft.net>
	<4CF45D6B.2070007@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: brian.haley@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47823
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752215Ab0K3DST (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Nov 2010 22:18:19 -0500
In-Reply-To: <4CF45D6B.2070007@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Brian Haley <brian.haley@hp.com>
Date: Mon, 29 Nov 2010 21:11:55 -0500

> On 11/29/2010 04:44 PM, David Miller wrote: 
>> +		case AF_INET6:
>> +			if (!ipv6_addr_cmp((struct in6_addr *)a,
>> +					   (struct in6_addr *)b))
>> +				return true;
>> +			break;
> 
> ipv6_addr_equal() ?

Yep, makes sense to me.
