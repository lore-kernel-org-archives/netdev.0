From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/2] tcp/dccp: better use of ephemeral ports
Date: Thu, 11 Feb 2016 08:58:52 -0800
Message-ID: <1455209932.22120.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454724538-13556-1-git-send-email-edumazet@google.com>
	 <20160211.114825.2144275138787010650.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f45.google.com ([74.125.82.45]:37527 "EHLO
	mail-wm0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbcBKQ7E (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Feb 2016 11:59:04 -0500
Received: by mail-wm0-f45.google.com with SMTP id g62so77520090wme.0
        for <netdev@vger.kernel.org>; Thu, 11 Feb 2016 08:59:03 -0800 (PST)
In-Reply-To: <20160211.114825.2144275138787010650.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-11 at 11:48 -0500, David Miller wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Fri,  5 Feb 2016 18:08:56 -0800
> 
> > Big servers have bloated bind table, making very hard to succeed
> > ephemeral port allocations, without special containers/namespace tricks.
> > 
> > This patch series extends the strategy added in commit 07f4c90062f8 
> > ("tcp/dccp: try to not exhaust ip_local_port_range in connect()").
> > 
> > Since ports used by connect() are much likely to be shared among them,
> > we give a hint to both bind() and connect() to keep the crowds separated
> > if possible.
> > 
> > Of course, if on a specific host an application needs to allocate ~30000
> > ports using bind(), it will still be able to do so. Same for ~30000 connect()
> > to a unique 2-tuple (dst addr, dst port)
> > 
> > New implemetation is also more friendly to softirqs and reschedules.
> 
> I'm getting rejects on the second patch, please respin and repost.
> 
> Thanks Eric.

Sure, let me take a look.
