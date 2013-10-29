From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net-next] ipv4: introduce new IP_MTU_DISCOVER mode IP_PMTUDISC_INTERFACE
Date: Tue, 29 Oct 2013 13:50:58 +0100
Message-ID: <20131029125058.GB15762@order.stressinduktion.org>
References: <20131026201158.GI15744@order.stressinduktion.org> <20131029.000844.1092862708536984032.davem@davemloft.net> <20131029120424.GD26185@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	fweimer@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:35963 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753183Ab3J2MvA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Oct 2013 08:51:00 -0400
Content-Disposition: inline
In-Reply-To: <20131029120424.GD26185@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 29, 2013 at 01:04:25PM +0100, Hannes Frederic Sowa wrote:
> The reason for this is, that __ip_rt_update_pmtu is called with zero mtu
> and will get clamped to min_pmtu. It is possible to tell people to also
> increase min_pmtu but I don't want to take the risk of breaking other
> applications on a DNS server given how the current semantics are.

It is actually difficult to select a reasonable mtu here given more than two
interfaces with different mtus.

Greetings,

  Hannes
