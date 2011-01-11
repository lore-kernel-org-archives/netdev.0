From: Stefani Seibold <stefani@seibold.net>
Subject: Re: [PATCH] new UDPCP Communication Protocol
Date: Tue, 11 Jan 2011 22:41:57 +0100
Message-ID: <1294782117.17531.18.camel@wall-e>
References: <1294779020.16410.2.camel@wall-e>
	 <20110111.125254.133402589.davem@davemloft.net>
	 <1294780480.17388.2.camel@wall-e>
	 <20110111.131953.180400101.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-15"
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, linux-kernel@vger.kernel.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	shemminger@vyatta.com, jj@chaosbits.net, daniel.baluta@gmail.com,
	jochen@jochen.org, hagen@jauu.net, torvalds@linux-foundation.org,
	pavel@ucw.cz
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www84.your-server.de ([213.133.104.84]:49360 "EHLO
	www84.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753902Ab1AKVk6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 16:40:58 -0500
In-Reply-To: <20110111.131953.180400101.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, den 11.01.2011, 13:19 -0800 schrieb David Miller:
> From: Stefani Seibold <stefani@seibold.net>
> Date: Tue, 11 Jan 2011 22:14:40 +0100
> 
> > If nobody need it and no user in the near future out there, why should i
> > implement this? That is dogmatic only!
> 
> It's a hard requirement, sorry.
> 
> And I want you to do it especially because it shows clearly how poor
> your implementation is, with all of it's code duplication.
> 

First it is not so much code duplication. It it less than 20 percent of
the whole code. And most of this code was adapted to the need of the
protocol.

Second, the design is may in your opinion poor. I like it. What is
really poor is the kernel_...() socket functions, which are only simple
wrapper of the system calls without any performance improvement, skb
support and memory saving.

IPv6 would not very hard to implement and will be done if i get an go. 

> You'll need yet another copy of all of this code to support ipv6.
> 
> Please implement this properly, and in doing so the ipv6 support will
> be very simple if not trivial.

The implementation is clean and fast, it has absolut no side effect. It
is save to merge and all requirement was solved.


