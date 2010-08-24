From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH RFC] net: save RX queue number in sock for
 dev_pick_tx() use
Date: Tue, 24 Aug 2010 17:45:29 +0100
Message-ID: <1282668329.2302.8.camel@achroite.uk.solarflarecom.com>
References: <1282640519-15541-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	"Pekka Savola (ipv6)" <pekkas@netcore.fi>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:49586 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755719Ab0HXQpf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Aug 2010 12:45:35 -0400
In-Reply-To: <1282640519-15541-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-08-24 at 17:01 +0800, Changli Gao wrote:
> For the packets sent out from a local server socket, we can use the queue
> from which the packets from the client socket are received.
> 
> It may help on a TCP or UDP server. Because I don't have a multiqueue NIC,
> I don't even test it.
[...]

There are some fairly cheap 1G multiqueue NICs around now (and even
several of the ARM embedded Ethernet controllers support multiqueue).

Could you compare this with my patch in
<http://thread.gmane.org/gmane.linux.network/158477>?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

