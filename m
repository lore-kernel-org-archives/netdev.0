From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Multicast routing stops functioning after 4G multicast packets recived.
Date: Tue, 7 Jan 2014 18:43:22 +0100
Message-ID: <20140107174322.GC30393@order.stressinduktion.org>
References: <20140107170145.317040@gmx.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Julian Anastasov <ja@ssi.bg>, netdev@vger.kernel.org
To: Bob Falken <NetFestivalHaveFun@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:45776 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753056AbaAGRnY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jan 2014 12:43:24 -0500
Content-Disposition: inline
In-Reply-To: <20140107170145.317040@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 07, 2014 at 06:01:44PM +0100, Bob Falken wrote:
> Hello,
> 
> I patched, kernel 3.2.53 yesterday,
> 8774002632packets, and ~9.1TB later, the multicast routing seems to function properly. :)
> 
> Kudos for fixing this.
> 
> I will keep checking the next days.
> 
> As for IPv6 MR, my current setup i.e: the Multicast source, does not support IPv6, so cannot do a check for that natively.
> 
> Unless I can translate IPv4 multicast into IPv6 multicast easily, using some iptable prerouting rules(?).

Thank you for testing!

I'll review the RCU regions again and will prepare the patches (before
introduction of ebc0ffae5dfb44 ("fib: RCU conversion of fib_lookup()")
and after.
