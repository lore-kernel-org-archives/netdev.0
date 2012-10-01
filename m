From: Dave Jones <davej@redhat.com>
Subject: Re: Possible networking regression in 3.6.0
Date: Mon, 1 Oct 2012 15:34:34 -0400
Message-ID: <20121001193434.GA14236@redhat.com>
References: <1348748042.5093.1168.camel@edumazet-glaptop>
 <50649567.2010704@googlemail.com>
 <1348779826.5093.1750.camel@edumazet-glaptop>
 <1348780624.5093.1767.camel@edumazet-glaptop>
 <50656C4A.8090302@googlemail.com>
 <1348831592.5093.2251.camel@edumazet-glaptop>
 <5068648C.7050005@googlemail.com>
 <1349034330.12401.210.camel@edumazet-glaptop>
 <506955F3.8050304@googlemail.com>
 <1349082950.12401.669.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Chris Clayton <chris2553@googlemail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gpiez@web.de
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62357 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754119Ab2JATel (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 15:34:41 -0400
Content-Disposition: inline
In-Reply-To: <1349082950.12401.669.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Oct 01, 2012 at 11:15:50AM +0200, Eric Dumazet wrote:
 > > 
 > > $ netstat -s
 > > Icmp:
 > >      4 ICMP messages received
 > >      4 input ICMP message failed.
 > >      ICMP input histogram:
 > >          echo replies: 4
 > 
 > So icmp replies come back and are delivered to host instead of being
 > forwarded.
 > 
 > I wonder if MASQUERADE broke...

I hit something that sounds just like this a few months back..
http://lists.openwall.net/netdev/2012/07/25/53

It "went away" a few builds later, but I've seen it happen
again from time to time.

	Dave
