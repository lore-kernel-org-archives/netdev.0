From: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
Subject: Re: Fwd: Linux stack performance drop (TCP and UDP) in 3.10 kernel in
 routed scenario
Date: Wed, 4 Jun 2014 23:33:44 +0530
Message-ID: <CAJMXqXa6JciuNM9V0WSRdDTzQ8M6OdYNeqLR+559VijgJeHROQ@mail.gmail.com>
References: <CAJMXqXZQ_S27LCZNJDjcQ9jy2qyJ0UT2nk+wdZOTQep+5rQZhQ@mail.gmail.com>
	<CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
	<1401885281.3645.245.camel@edumazet-glaptop2.roam.corp.google.com>
	<CAJMXqXaqXG03e+OHr0aMh9x_N4BzBVWTkQLKgNVvq-QmDaX5Ng@mail.gmail.com>
	<1401893993.3645.253.camel@edumazet-glaptop2.roam.corp.google.com>
	<1401899666.3645.255.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	davem@davemloft.ne
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f170.google.com ([209.85.128.170]:52708 "EHLO
	mail-ve0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751202AbaFDSDp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 14:03:45 -0400
Received: by mail-ve0-f170.google.com with SMTP id db11so9331590veb.29
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 11:03:44 -0700 (PDT)
In-Reply-To: <1401899666.3645.255.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

On Wed, Jun 4, 2014 at 10:04 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> On Wed, 2014-06-04 at 07:59 -0700, Eric Dumazet wrote:
>
>> Its yet not clear why a router has to checksum TCP packets.
>>
>> Maybe a conntracking requirement...
>
>
> Right... you can tweak nf_conntrack_checksum
>

Will definitely try this option but as you mentioned with a limited
cache in an embedded router environment checking the routing table for
the dst for every packet (routed scenario) is a heavy operation which
can still lead to poor stack performance.

So, I request you to please suggest on how to address this topic w.r.t
embedded devices ( routers) which has limited memory resources ?

Thanks and Regards,
Suprasad.
