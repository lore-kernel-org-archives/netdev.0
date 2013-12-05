From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: Possible IPv6 fragmentation/pmtud bug
Date: Thu, 5 Dec 2013 21:18:57 +0100
Message-ID: <20131205201856.GC21745@order.stressinduktion.org>
References: <2134F8430051B64F815C691A62D9831816F612@XCH-BLV-504.nw.nos.boeing.com> <2134F8430051B64F815C691A62D9831816F6A4@XCH-BLV-504.nw.nos.boeing.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Templin, Fred L" <Fred.L.Templin@boeing.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:34022 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752675Ab3LEUS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 15:18:58 -0500
Content-Disposition: inline
In-Reply-To: <2134F8430051B64F815C691A62D9831816F6A4@XCH-BLV-504.nw.nos.boeing.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 05, 2013 at 08:13:25PM +0000, Templin, Fred L wrote:
> Another clue that I should have mentioned in my initial message; the
> "hosts", "routers" and "links" are not physical nodes but rather
> network namespace virtual nodes running within a single linux 3.10.17
> emulation server. Could there be some sort of weird "cross-talk"
> between VMs that is making the router believe it is a host?

That is probable. With a quick test I could not reproduce it. I guess we don't
reset skb->local_df after creation. I'll check it out.

Thanks for the report,

  Hannes
