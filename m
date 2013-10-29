From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 14:11:38 +0100
Message-ID: <20131029131138.GA16253@order.stressinduktion.org>
References: <20131028.204306.2213130677400093266.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com> <20131029124010.GA15762@order.stressinduktion.org> <1383052163.5464.28.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Laight <David.Laight@ACULAB.COM>,
	David Miller <davem@davemloft.net>, jiri@resnulli.us,
	vyasevich@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org,
	Dave Taht <dave.taht@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:36030 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755175Ab3J2NLj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 09:11:39 -0400
Content-Disposition: inline
In-Reply-To: <1383052163.5464.28.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 06:09:23AM -0700, Eric Dumazet wrote:
> On Tue, 2013-10-29 at 13:40 +0100, Hannes Frederic Sowa wrote:
> 
> > Yes, this is a very unfortunate situation. From my experience it is not that
> > easy to get a patch merged into isc-dhcp.
> > 
> > It seems not that invasive to switch from af_packet to an udp socket with
> > SO_BROADCAST set.
> 
> Has anyone cooked and submitted such a patch ?

Not me, my patch was intended for the server side (dhcrelay correctly
choosing source addresses).

> I can visit ISC with a hammer if needed ;)

Actually that is a very big motivation for me to try to come up with a
patch at the weekend. ;-)
