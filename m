From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Mon, 15 Oct 2012 09:43:32 +0200
Message-ID: <1350287012.21172.17421.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
	 <1350246414.21172.17144.camel@edumazet-glaptop>
	 <1350246481.21172.17147.camel@edumazet-glaptop>
	 <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
	 <1350248858.21172.17197.camel@edumazet-glaptop>
	 <CAO_aot6w9yaWacK9kE66m+Lv0LWXY9hKzLH8b=1dp=23fo_W2A@mail.gmail.com>
	 <1350250542.21172.17229.camel@edumazet-glaptop>
	 <CAO_aot4RiTbUd=7L5e4btLEeJvgy0B3iswaXo8m3AP2qp9Z0TQ@mail.gmail.com>
	 <1350252091.21172.17257.camel@edumazet-glaptop>
	 <CAO_aot6j2TPe9yxnA1ktMQsfnnWF1XwmCrQUmCcfOqCqbc6dZA@mail.gmail.com>
	 <1350279753.21172.17290.camel@edumazet-glaptop>
	 <1350285275.22442.17.camel@joe-AO722>
	 <1350286790.21172.17414.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33000 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750997Ab2JOHnf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 03:43:35 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2257090bkc.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 00:43:34 -0700 (PDT)
In-Reply-To: <1350286790.21172.17414.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-15 at 09:39 +0200, Eric Dumazet wrote:

> So if you want to help, grab ntpd sources, reproduce the problem, make a
> bisection so that we have a clue of the kernel change that trigger the
> problem, and so on...
> 
> That would be really awesome, given Jan is not a kernel developer, we
> cannot really ask him to do this himself.
> 

And before you ask, on my machine, ntpd does listen to ::1, so I dont
have the problem. If I cant reproduce it, I probably wont fix the
problem.

...

ntpd    2964  ntp   16u     IPv4              17966      0t0     UDP *:ntp 
ntpd    2964  ntp   17u     IPv6              17967      0t0     UDP *:ntp 
ntpd    2964  ntp   18u     IPv4              17973      0t0     UDP 127.0.0.1:ntp 
ntpd    2964  ntp   19u     IPv4              17974      0t0     UDP 172.30.42.8:ntp 
ntpd    2964  ntp   20u     IPv6              17975      0t0     UDP [::1]:ntp 
ntpd    2964  ntp   21u     IPv6              17976      0t0     UDP [fe80::222:15ff:fe87:3ff6]:ntp 
ntpd    2964  ntp   22u  netlink                         0t0   17977 ROUTE
