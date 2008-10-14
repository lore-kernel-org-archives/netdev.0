From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH 04/14] sch_netem: Use requeue list instead of
	ops->requeue()
Date: Tue, 14 Oct 2008 20:04:35 +0200
Message-ID: <20081014180435.GB2548@ami.dom.local>
References: <fe92ba9380e7da89b674cc58fcb5bc1dae69e0c6.1223973003.git.jarkao2@gmail.com> <20081014095349.GE10804@ff.dom.local> <20081014082235.10b46637@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ey-out-2122.google.com ([74.125.78.24]:62562 "EHLO
	ey-out-2122.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751392AbYJNSEF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Oct 2008 14:04:05 -0400
Received: by ey-out-2122.google.com with SMTP id 6so832720eyi.37
        for <netdev@vger.kernel.org>; Tue, 14 Oct 2008 11:03:56 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20081014082235.10b46637@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 14, 2008 at 08:22:35AM -0700, Stephen Hemminger wrote:
...
> This won't work for the case where time based reordering changes the packet
> sent.  The current code works like this:
> 
>     Packet marked to be sent at some time (+101ms)
>     new packet is queued and the random delay computes smaller delta (+87ms)
>     new packet will go out in first.
> 
> This was done for compatibility with NISTnet, so research that wanted to reproduce
> NISTnet results could use netem.
> 

I've decided to withdraw this all, but I hope these explanations should
be useful for me (to be more careful around here) in the future.

Thanks,
Jarek P.
