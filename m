From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Mon, 15 Oct 2012 09:39:50 +0200
Message-ID: <1350286790.21172.17414.camel@edumazet-glaptop>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>,
	netdev@vger.kernel.org
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:39281 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750850Ab2JOHjx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Oct 2012 03:39:53 -0400
Received: by mail-bk0-f46.google.com with SMTP id jk13so2255419bkc.19
        for <netdev@vger.kernel.org>; Mon, 15 Oct 2012 00:39:52 -0700 (PDT)
In-Reply-To: <1350285275.22442.17.camel@joe-AO722>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-15 at 00:14 -0700, Joe Perches wrote:
> On Mon, 2012-10-15 at 07:42 +0200, Eric Dumazet wrote:
> > So ntpd doesnt listen on ntp messages sent on ::1
> 
> So how is it a regression?
> How did it ever work before?
> Did some kernel change cause it to fail?
> If so, are there more apps like it?
> 

Thanks for your help Joe.

What about trying to answer yourself to these questions ?

You can have a valid patch that uncover a bug in an application, it
happens everyday.

So if you want to help, grab ntpd sources, reproduce the problem, make a
bisection so that we have a clue of the kernel change that trigger the
problem, and so on...

That would be really awesome, given Jan is not a kernel developer, we
cannot really ask him to do this himself.
