From: David Miller <davem@davemloft.net>
Subject: Re: IPV6 loopback bound socket succeeds connecting to remote host
Date: Sun, 19 Dec 2010 22:43:50 -0800 (PST)
Message-ID: <20101219.224350.260095315.davem@davemloft.net>
References: <4CF75BC3.1020606@cn.fujitsu.com>
	<20101216.121805.59690737.davem@davemloft.net>
	<4D0EF840.2020108@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: albertpretorius@yahoo.co.uk, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org, pekkas@netcore.fi, jmorris@namei.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:32826
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753510Ab0LTGnW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 01:43:22 -0500
In-Reply-To: <4D0EF840.2020108@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Mon, 20 Dec 2010 14:31:28 +0800

> David Miller wrote, at 12/17/2010 04:18 AM:
>> Your approach will only modify socket based route handling, it will
>> not handle the ipv6 forwarding case which as per the quoted RFC
>> sections must be handled too.
> 
> For the ipv6 forwarding case, we have done the check in ip6_forward().
> 
>  493                 int addrtype = ipv6_addr_type(&hdr->saddr);
>  494 
>  495                 /* This check is security critical. */
>  496                 if (addrtype == IPV6_ADDR_ANY ||
>  497                     addrtype & (IPV6_ADDR_MULTICAST | IPV6_ADDR_LOOPBACK))
>  498                         goto error;

Indeed, thanks for pointing this out.
