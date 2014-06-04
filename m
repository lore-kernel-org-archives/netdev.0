From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fwd: Linux stack performance drop (TCP and UDP) in 3.10 kernel
 in routed scenario
Date: Wed, 04 Jun 2014 11:44:18 -0700
Message-ID: <1401907458.3645.257.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJMXqXZQ_S27LCZNJDjcQ9jy2qyJ0UT2nk+wdZOTQep+5rQZhQ@mail.gmail.com>
	 <CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
	 <1401885281.3645.245.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJMXqXaqXG03e+OHr0aMh9x_N4BzBVWTkQLKgNVvq-QmDaX5Ng@mail.gmail.com>
	 <1401893993.3645.253.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CACP96tQsfN9REHKZBJ7uWEr5kK04ScFPFMC8Zx7PMykoQg3yyg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Suprasad Mutalik Desai <suprasad.desai@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.ne>
To: sowmini varadhan <sowmini05@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f172.google.com ([209.85.192.172]:50605 "EHLO
	mail-pd0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750742AbaFDSoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 14:44:20 -0400
Received: by mail-pd0-f172.google.com with SMTP id fp1so6415654pdb.31
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 11:44:19 -0700 (PDT)
In-Reply-To: <CACP96tQsfN9REHKZBJ7uWEr5kK04ScFPFMC8Zx7PMykoQg3yyg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-06-04 at 14:26 -0400, sowmini varadhan wrote:
> On Wed, Jun 4, 2014 at 10:59 AM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > Problem with IPv4 route cache is that is was too easy to flood it and
> > get worse performance.
> >
> > It had simply huge memory costs, and non predictable behavior [1]
> 
> Can you elaborate? Caches usually have an upper bound on
> the memory to be consumed by the cache, and from my reading
> of the 2.6.32 code, seems like it also had such limits (there was
> a sysctl tunable to turn off hashing, and rt_intern_hash() also had
> other bounds. Were these not enough?


http://vger.kernel.org/~davem/columbia2012.pdf


For gory details :

git log net/ipv4/route.c
