From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] ipv4: arp: update neighbour address when a gratuitous arp is received and arp_accept is set
Date: Wed, 25 Dec 2013 12:37:10 +0100
Message-ID: <20131225113710.GR14073@order.stressinduktion.org>
References: <1387923422-4247-1-git-send-email-noureddine@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Salam Noureddine <noureddine@aristanetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:50710 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751813Ab3LYLhM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Dec 2013 06:37:12 -0500
Content-Disposition: inline
In-Reply-To: <1387923422-4247-1-git-send-email-noureddine@aristanetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 24, 2013 at 02:17:02PM -0800, Salam Noureddine wrote:
> Gratuitous arp packets are useful in switchover scenarios to update
> client arp tables as quickly as possible. Currently, the mac address
> of a neighbour is only updated after a locktime period has elapsed
> since the last update. In most use cases such delays are unacceptable
> for network admins. Moreover, the "updated" field of the neighbour
> stucture doesn't record the last time the address of a neighbour
> changed but records any change that happens to the neighbour. This is
> clearly a bug since locktime uses that field as meaning "addr_updated".
> With this observation, I was able to perpetuate a stale address by
> sending a stream of gratuitous arp packets spaced less than locktime
> apart. With this change the address is updated when a gratuitous arp
> is received and the arp_accept sysctl is set.
> 
> Signed-off-by: Salam Noureddine <noureddine@aristanetworks.com>

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks!
