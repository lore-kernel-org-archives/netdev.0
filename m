From: Brian Haley <brian.haley@hp.com>
Subject: Re: ipv6_addr_type() and mapped IPv4 loopback
Date: Mon, 03 Nov 2008 21:33:04 -0500
Message-ID: <490FB460.2010501@hp.com>
References: <06930890-5BC3-4BE2-97CC-B3F6DF33B794@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Chuck Lever <chuck.lever@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0008.atlanta.hp.com ([15.192.0.45]:25563 "EHLO
	g5t0008.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752277AbYKDCdG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Nov 2008 21:33:06 -0500
In-Reply-To: <06930890-5BC3-4BE2-97CC-B3F6DF33B794@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chuck Lever wrote:
> The __ipv6_addr_type() function does not recognize the mapped IPv4 
> loopback address:
> 
>    ::ffff:7f00:0001
> 
> as type IPV6_ADDR_LOOPBACK.  Is this intentional?

I would think that since the IPv6 loopback address is ::1, and 
ipv4-mapped is ::ffff:* that this would be IPV6_ADDR_MAPPED.  That's 
what RFC 4291 seems to say.

-Brian
