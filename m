From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Linux stack performance drop (TCP and UDP) in 3.10 kernel in
 routed scenario
Date: Wed, 04 Jun 2014 23:32:27 -0700
Message-ID: <1401949947.3645.267.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAJMXqXZQ_S27LCZNJDjcQ9jy2qyJ0UT2nk+wdZOTQep+5rQZhQ@mail.gmail.com>
	 <CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
	 <20140604.121819.2149110045488849780.davem@davemloft.net>
	 <CAJMXqXZV+tGPi5_d-ndeLYfx-yV6WiyDRBaqMcs0dYNTKfZHrw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:60666 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750776AbaFEGc3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Jun 2014 02:32:29 -0400
Received: by mail-pd0-f174.google.com with SMTP id r10so636980pdi.33
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 23:32:28 -0700 (PDT)
In-Reply-To: <CAJMXqXZV+tGPi5_d-ndeLYfx-yV6WiyDRBaqMcs0dYNTKfZHrw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-06-05 at 07:47 +0530, Suprasad Mutalik Desai wrote:

> So, I request you to please suggest on how to address this topic w.r.t
> embedded devices ( routers) which has limited memory resources ?

Hmm... How do you catch a cloud and pin it down ?

More seriously...

What about removing this tcp checksum ?

This is the main cost according to your performance data.

Then, you are free to implement a cache of your own where it might help.

Tom Herbert added partial cache on tunnels for example in linux-3.15 or
something like that.
