From: Brian Haley <brian.haley@hp.com>
Subject: Re: Help On function to get IPV6 address of an interface in kernel
Date: Thu, 04 Mar 2010 11:17:39 -0500
Message-ID: <4B8FDD23.3070000@hp.com>
References: <20100304094103.GA6599@mohan-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mohan Reddy <mohanreddykv@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0184.atlanta.hp.com ([15.193.32.61]:16998 "EHLO
	g6t0184.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754256Ab0CDQRn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 4 Mar 2010 11:17:43 -0500
In-Reply-To: <20100304094103.GA6599@mohan-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mohan Reddy wrote:
> Hi,
> 
> Is there a function or a way in kernel to get an interface ipv6 address if interface name or net_device object is known? I searched in the kernel i got a function ipv6_get_ifaddr(). But it is expecting an ipv6 address as a parameter. 

What type of IPv6 address?  For link-locals you can use ipv6_get_lladdr(), but
for others ipv6_dev_get_saddr() is more comprehensive, but you'll need a
destination address.  There's lots of reference code in addrconf.c to do
other things.

-Brian
