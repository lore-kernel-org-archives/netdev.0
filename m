From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: use interface mtu for determining if packet-too-big should be send
Date: Mon, 16 Dec 2013 15:01:24 +0100
Message-ID: <20131216140124.GA5164@order.stressinduktion.org>
References: <20131216080914.GA28677@order.stressinduktion.org> <1387201782.19078.230.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:59075 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753882Ab3LPOB0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 09:01:26 -0500
Content-Disposition: inline
In-Reply-To: <1387201782.19078.230.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 16, 2013 at 05:49:42AM -0800, Eric Dumazet wrote:
> On Mon, 2013-12-16 at 09:09 +0100, Hannes Frederic Sowa wrote:
> > IPv6 forwarding path should also not depend on the path mtu values to
> > judge if a packet should get dropped and an ICMP PTB should be returned.
> > 
> > For the accompanying change in IPv4, have a look at "ipv4: introduce
> > ip_dst_mtu_secure and protect forwarding path against pmtu spoofing".
> > 
> 
> No commit sha1 (truncated to 12 digits) ?

The patch is not yet committed.

> > I needed to move in6_dev_dev around to keep ip6_dst_mtu_secure as a static
> > inline function in the header and to keep header dependencies happy.
> > 
> > For the IPv4 change, see patch "ipv4: introduce ip_dst_mtu_secure and
> > protect forwarding path against pmtu spoofing".
> 
> Redundant sentence ?

Hehe, I have no idea how that happend. :)

> And no documentation for the new setting.
> 
> git grep -n forward_use_pmtu Documentation

The IPv4 patch introduces the documentation for the flag but is in the
wrong section (IPv4). I'll send a v2 later today and will duplicate it
for the IPv6 section.

Thanks,

  Hannes
