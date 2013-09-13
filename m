From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: GRE support for IPv6
Date: Fri, 13 Sep 2013 14:46:30 -0700
Message-ID: <20130913144630.1cb1863c@samsung-9>
References: <CAF0Lin0xTW4oQ0OQaTzJhoS6XV3nbb8yZx8jDMAcGyJo9zTs9A@mail.gmail.com>
	<CAF0Lin2-ooC6iQCwjnf5196cfy0Xii6H5prS4CEsjeJVAFYcyA@mail.gmail.com>
	<20130913164404.GA32431@order.stressinduktion.org>
	<2134F8430051B64F815C691A62D98318108CA3@XCH-BLV-504.nw.nos.boeing.com>
	<20130913210105.GD32431@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Templin, Fred L" <Fred.L.Templin@boeing.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>, xeb@mail.ru
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:47936 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755728Ab3IMVqe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Sep 2013 17:46:34 -0400
Received: by mail-pa0-f42.google.com with SMTP id lj1so3049882pab.15
        for <netdev@vger.kernel.org>; Fri, 13 Sep 2013 14:46:34 -0700 (PDT)
In-Reply-To: <20130913210105.GD32431@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 13 Sep 2013 23:01:05 +0200
Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:

> On Fri, Sep 13, 2013 at 06:32:53PM +0000, Templin, Fred L wrote:
> > Someone recently added the module ./net/ipv6/ip6_gre.c to the
> > kernel, but I cannot find any obvious way to configure it using
> > iproute2. Is there any userland code available for turning on
> > GRE tunnels for IPv6?
> 
> I guess it got lost somehow:
> 
> http://patchwork.ozlabs.org/patch/173836/
> 

The patch was submitted before the kernel code made it to Linus.
And was not resubmitted. To deal with this in later releases I started
keeping a next branch but that only started after 3.10
