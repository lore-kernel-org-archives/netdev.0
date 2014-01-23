From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Setting mac address of loopback device
Date: Fri, 24 Jan 2014 00:49:20 +0100
Message-ID: <20140123234920.GM7269@order.stressinduktion.org>
References: <CAHA+R7Poj99BjOq55st3hU-2-p+gqoeHMCDCSJjT5eEocbKwMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev <netdev@vger.kernel.org>
To: Cong Wang <cwang@twopensource.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:33544 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750881AbaAWXtW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 18:49:22 -0500
Content-Disposition: inline
In-Reply-To: <CAHA+R7Poj99BjOq55st3hU-2-p+gqoeHMCDCSJjT5eEocbKwMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 11:53:49AM -0800, Cong Wang wrote:
> BTW, how to change route to redirect _local_ traffic (that is packets
> sending to itself) to a non-loopback device? I tried to modify local
> route table, but have no luck to make it working.

Have you seen the route_localnet sysctl? It should avoid the check for
loopback addresses when building outgoing route.

Greetings,

  Hannes
