From: Cong Wang <cwang@twopensource.com>
Subject: Re: Setting mac address of loopback device
Date: Thu, 23 Jan 2014 16:03:29 -0800
Message-ID: <CAHA+R7PtkiQRgJwTJ4Pq2zTWs9N5x22VFEcK4QMv65SG7bX1Tw@mail.gmail.com>
References: <CAHA+R7Poj99BjOq55st3hU-2-p+gqoeHMCDCSJjT5eEocbKwMQ@mail.gmail.com>
	<20140123234920.GM7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: Cong Wang <cwang@twopensource.com>,
	David Miller <davem@davemloft.net>, stephen@networkplumber.org,
	netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f177.google.com ([209.85.217.177]:64763 "EHLO
	mail-lb0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755744AbaAXADa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Jan 2014 19:03:30 -0500
Received: by mail-lb0-f177.google.com with SMTP id z5so2010499lbh.36
        for <netdev@vger.kernel.org>; Thu, 23 Jan 2014 16:03:29 -0800 (PST)
In-Reply-To: <20140123234920.GM7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 23, 2014 at 3:49 PM, Hannes Frederic Sowa
<hannes@stressinduktion.org> wrote:
> On Thu, Jan 23, 2014 at 11:53:49AM -0800, Cong Wang wrote:
>> BTW, how to change route to redirect _local_ traffic (that is packets
>> sending to itself) to a non-loopback device? I tried to modify local
>> route table, but have no luck to make it working.
>
> Have you seen the route_localnet sysctl? It should avoid the check for
> loopback addresses when building outgoing route.

I noticed it, the doc said:

This enables the use of 127/8 for local routing purposes.

but I don't care 127/8 traffic at all, only the traffic sending to itself
via a non-127/8 IP. :(

Or the doc is not accurate?
