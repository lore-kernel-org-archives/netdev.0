From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Stable regression with 'tcp: allow splice() to build full TSO
 packets'
Date: Thu, 17 May 2012 19:38:25 +0100
Message-ID: <1337279905.2496.23.camel@bwh-desktop.uk.solarflarecom.com>
References: <20120517121800.GA18052@1wt.eu> <20120517150157.GA19274@1wt.eu>
	 <1337269380.3403.10.camel@edumazet-glaptop> <20120517155621.GK14498@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, <netdev@vger.kernel.org>
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:30687 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1762310Ab2EQSic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 14:38:32 -0400
In-Reply-To: <20120517155621.GK14498@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 17:56 +0200, Willy Tarreau wrote:
[...]
> The NIC does not support TSO but I've seen an alternate driver for this
> NIC which pretends to do TSO and in fact builds header frags so that the
> NIC is able to send all frames at once. I think it's already what GSO is
> doing but I'm wondering whether it would be possible to get more speed
> by doing this than by relying on GSO to (possibly) split the frags earlier.
[...]

Yes, GSO has some overhead for skb allocation and additional function
calls that you can avoid by doing 'TSO' in the driver.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
