From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv6: use interface mtu for determining if packet-too-big should be send
Date: Tue, 17 Dec 2013 22:52:38 +0100
Message-ID: <20131217215238.GB27460@order.stressinduktion.org>
References: <20131216080914.GA28677@order.stressinduktion.org> <1387201782.19078.230.camel@edumazet-glaptop2.roam.corp.google.com> <20131216140124.GA5164@order.stressinduktion.org> <20131217.164256.473228543329254152.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34689 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752004Ab3LQVwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 16:52:39 -0500
Content-Disposition: inline
In-Reply-To: <20131217.164256.473228543329254152.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 17, 2013 at 04:42:56PM -0500, David Miller wrote:
> From: Hannes Frederic Sowa <hannes@stressinduktion.org>
> Date: Mon, 16 Dec 2013 15:01:24 +0100
> 
> > On Mon, Dec 16, 2013 at 05:49:42AM -0800, Eric Dumazet wrote:
> >> On Mon, 2013-12-16 at 09:09 +0100, Hannes Frederic Sowa wrote:
> >> > IPv6 forwarding path should also not depend on the path mtu values to
> >> > judge if a packet should get dropped and an ICMP PTB should be returned.
> >> > 
> >> > For the accompanying change in IPv4, have a look at "ipv4: introduce
> >> > ip_dst_mtu_secure and protect forwarding path against pmtu spoofing".
> >> > 
> >> 
> >> No commit sha1 (truncated to 12 digits) ?
> > 
> > The patch is not yet committed.
> 
> It's confusing to propose an ipv6 version of an ipv4 patch that hasn't
> been integrated yet, please don't do this.

Ok, I'll do next time, sorry. I saw you still consider the IPv4 one, so I'll
just wait and resubmit this one as soon as I have feedback.
