From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [patch net-next] ipv6: allow userspace to create address with IFLA_F_TEMPORARY flag
Date: Tue, 29 Oct 2013 13:40:10 +0100
Message-ID: <20131029124010.GA15762@order.stressinduktion.org>
References: <20131028.204306.2213130677400093266.davem@davemloft.net> <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, jiri@resnulli.us,
	vyasevich@gmail.com, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	thaller@redhat.com, stephen@networkplumber.org
To: David Laight <David.Laight@ACULAB.COM>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35924 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753019Ab3J2MkL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 08:40:11 -0400
Content-Disposition: inline
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B73BB@saturn3.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 09:37:06AM -0000, David Laight wrote:
> > Note that you don't even need to put the DHCP protocol core into the
> > kernel to fix the promiscuous problem.  You just have to use the
> > current kernel interfaces correctly.
> > 
> > It used to be the case a very long time ago that you couldn't even
> > receive broadcast UDP datagrams on a socket until an address was
> > configured on it.
> > 
> > So everyone turns on promiscuous mode and uses RAW sockets or
> > AF_PACKET.
> > 
> > Stupid?  yes.
> 
> Not only that, but the dhcp client could use a normal UDP socket
> to keep the lease renewed - I suspect it has only ever needed
> to use the BPF interface (I didn't think it set promiscuous)
> when acquiring the initial lease.

Yes, this is a very unfortunate situation. From my experience it is not that
easy to get a patch merged into isc-dhcp.

It seems not that invasive to switch from af_packet to an udp socket with
SO_BROADCAST set.

Greetings,

  Hannes
