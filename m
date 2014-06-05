From: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
Subject: Re: Linux stack performance drop (TCP and UDP) in 3.10 kernel in
 routed scenario
Date: Thu, 5 Jun 2014 07:47:48 +0530
Message-ID: <CAJMXqXZV+tGPi5_d-ndeLYfx-yV6WiyDRBaqMcs0dYNTKfZHrw@mail.gmail.com>
References: <CAJMXqXZQ_S27LCZNJDjcQ9jy2qyJ0UT2nk+wdZOTQep+5rQZhQ@mail.gmail.com>
	<CAJMXqXaf6P=F4+jLhRFrv9GTRK6K9h5boSgyVCS7e9C31a_YzA@mail.gmail.com>
	<20140604.121819.2149110045488849780.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	davem@davemloft.ne
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve0-f176.google.com ([209.85.128.176]:52200 "EHLO
	mail-ve0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752173AbaFECRt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2014 22:17:49 -0400
Received: by mail-ve0-f176.google.com with SMTP id jz11so418961veb.35
        for <netdev@vger.kernel.org>; Wed, 04 Jun 2014 19:17:48 -0700 (PDT)
In-Reply-To: <20140604.121819.2149110045488849780.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David,

On Thu, Jun 5, 2014 at 12:48 AM, David Miller <davem@davemloft.net> wrote:
> From: Suprasad Mutalik Desai <suprasad.desai@gmail.com>
> Date: Wed, 4 Jun 2014 14:34:10 +0530
>
>> I guess plain routing scenario was NOT thought through while removing
>> the routing cache code.
>
> It is exactly the scenerio that was considered.
>
> The routing cache was susceptible to trivial denial of service
> attacks, it therefore had to be removed.
>
> It also scaled poorly with large numbers of active flows.

Based on your and Eric's explanation , i clearly understand the
purpose of removing route cache.

But as there was no alternative proposed after removing route cache
mechanism, this is causing a side effect of low throughput in an
embedded router scenario with limited cache and memory resources. With
a limited cache in an embedded router environment checking the routing
table for the dst for every packet (routed scenario) is a heavy
operation which can lead to poor stack  performance.

So, I request you to please suggest on how to address this topic w.r.t
embedded devices ( routers) which has limited memory resources ?

Thanks and Regards,
Suprasad.
