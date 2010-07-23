From: Mikael Abrahamsson <swmike@swm.pp.se>
Subject: Re: IPv6 Anycast?
Date: Fri, 23 Jul 2010 07:51:34 +0200 (CEST)
Message-ID: <alpine.DEB.1.10.1007230748380.9875@uplift.swm.pp.se>
References: <4C48B90B.60304@actusa.net> <alpine.DEB.1.10.1007230554240.9875@uplift.swm.pp.se> <4C491AD4.9070103@actusa.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: netdev@vger.kernel.org
To: Stuart Sheldon <stu@actusa.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from swm.pp.se ([212.247.200.143]:51952 "EHLO uplift.swm.pp.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753572Ab0GWFvf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 Jul 2010 01:51:35 -0400
In-Reply-To: <4C491AD4.9070103@actusa.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 22 Jul 2010, Stuart Sheldon wrote:

> Yea, I'm sure...
>
> We use Linux for routers as well as servers and workstations. Since I
> sent this I've discovered that by default, when a Linux system has IPv6
> forwarding turned on, it adds the <network>::/64 anycast router
> addresses on all the interfaces (as per rfc 2526).
>
> What I'm actually looking to do is (change / add) other addresses the to
> anycast6 list to work in an existing configuration that does not use the
> rfc 2526 anycast router address.
>
> Is there a command line method of setting up these anycast addresses?

In routers, this is done by adding the IP address to a loopback interface 
and announcing the address using a routing protocol, I don't see why this 
can't be done on a linux box?

-- 
Mikael Abrahamsson    email: swmike@swm.pp.se
