From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Sun, 5 Jan 2014 11:41:45 +0100
Message-ID: <20140105104145.GF25828@order.stressinduktion.org>
References: <20131219144816.33310@gmx.com> <alpine.LFD.2.11.1401042143330.1598@ja.home.ssi.bg> <20140104233840.GD25828@order.stressinduktion.org> <alpine.LFD.2.11.1401051050320.1538@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Bob Falken <NetFestivalHaveFun@gmx.com>, netdev@vger.kernel.org
To: Julian Anastasov <ja@ssi.bg>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39914 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750992AbaAEKlq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 5 Jan 2014 05:41:46 -0500
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1401051050320.1538@ja.home.ssi.bg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 05, 2014 at 10:56:55AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Sun, 5 Jan 2014, Hannes Frederic Sowa wrote:
> 
> > I guess we should just try. I somehow forgot to look after that. Thanks
> > for reminding, Julian.
> 
> 	If that patch solves the problem, do not forget
> to include same fix for ip6mr_fib_lookup(). As for net/decnet/,
> it looks ok, it uses fib_rule_put() in dn_fib_res_put().

Thanks, I had IPv6 on my radar but did not check for other callers.

Greetings,

  Hannes
