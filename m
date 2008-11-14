From: Brian Haley <brian.haley@hp.com>
Subject: Re: ipv6 route configuration
Date: Fri, 14 Nov 2008 13:09:49 -0500
Message-ID: <491DBEED.3090009@hp.com>
References: <3E7B3A98D9974986B65CC4E3C9409B3C@samsung4qkw9nm>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Mohan Lal Jangir <mohanlal@samsung.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:45555 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753578AbYKNSJx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Nov 2008 13:09:53 -0500
In-Reply-To: <3E7B3A98D9974986B65CC4E3C9409B3C@samsung4qkw9nm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mohan Lal Jangir wrote:
> [foo:/root] route -A inet6 add 2::/64 gw 2::1 dev eth5
> SIOCADDRT: Invalid argument
> [foo:/root]
> Could someone please tell why route addition tells invalid argument ?

Because 2::1 is in the reserved address space (see 
http://www.iana.org/assignments/ipv6-address-space) and the kernel needs 
to have a unicast address for the gateway.  You could try using the 
link-local address (which is preferred) for that system instead.  Or use 
a real global prefix or generate a ULA.

-Brian
