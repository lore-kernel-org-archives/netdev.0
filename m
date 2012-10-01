From: David Miller <davem@davemloft.net>
Subject: Re: Possible networking regression in 3.6.0
Date: Mon, 01 Oct 2012 16:01:15 -0400 (EDT)
Message-ID: <20121001.160115.1816241312626722150.davem@davemloft.net>
References: <506955F3.8050304@googlemail.com>
	<1349082950.12401.669.camel@edumazet-glaptop>
	<20121001193434.GA14236@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, chris2553@googlemail.com,
	netdev@vger.kernel.org, gpiez@web.de
To: davej@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40524 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752168Ab2JAUBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Oct 2012 16:01:22 -0400
In-Reply-To: <20121001193434.GA14236@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dave Jones <davej@redhat.com>
Date: Mon, 1 Oct 2012 15:34:34 -0400

> On Mon, Oct 01, 2012 at 11:15:50AM +0200, Eric Dumazet wrote:
>  > > 
>  > > $ netstat -s
>  > > Icmp:
>  > >      4 ICMP messages received
>  > >      4 input ICMP message failed.
>  > >      ICMP input histogram:
>  > >          echo replies: 4
>  > 
>  > So icmp replies come back and are delivered to host instead of being
>  > forwarded.
>  > 
>  > I wonder if MASQUERADE broke...
> 
> I hit something that sounds just like this a few months back..
> http://lists.openwall.net/netdev/2012/07/25/53
> 
> It "went away" a few builds later, but I've seen it happen
> again from time to time.

Yep I remembe that report.

If you can find a way to more reliably trigger the case, that would
help us immensely.
