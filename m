From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH net-next 2/2] udp: add sk opt to allow sending pkt
 with src 0.0.0.0
Date: Thu, 14 Nov 2013 15:00:24 -0500 (EST)
Message-ID: <20131114.150024.679596278327684470.davem@davemloft.net>
References: <1383958474-6255-2-git-send-email-nicolas.dichtel@6wind.com>
	<20131111.001803.110603937316567461.davem@davemloft.net>
	<20131114143154.GD26901@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.dichtel@6wind.com, netdev@vger.kernel.org,
	David.Laight@ACULAB.COM, jiri@resnulli.us, vyasevich@gmail.com,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, thaller@redhat.com, stephen@networkplumber.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:52353 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755568Ab3KNUA1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Nov 2013 15:00:27 -0500
In-Reply-To: <20131114143154.GD26901@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 14 Nov 2013 15:31:54 +0100

> Do you have an idea how to deal with the rp_filter issue if no ip
> address is set? Should we relax it in such cases?

I think it is kind of pointless to protect ourselves from locally
generated packets, for which the flow ID was explicitly asked for
by the application.

So yes I think relaxing rp_filter in such cases makes sense.
