From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: regression when connecting to ipv6 localhost
Date: Sun, 14 Oct 2012 23:02:29 +0200
Message-ID: <1350248549.21172.17188.camel@edumazet-glaptop>
References: <CAO_aot5U16KLjqtXp2ZS7d+T0WvVY7OXPaA3t2bbN=uvboVV3Q@mail.gmail.com>
	 <1350242941.21172.17023.camel@edumazet-glaptop>
	 <CAO_aot7BQqob=V9MEDSFnmCCNsxgjghC5e3NuQonqY8GCkV1Og@mail.gmail.com>
	 <1350244485.21172.17077.camel@edumazet-glaptop>
	 <CAO_aot7wZAqqQForAe-9aLnALqm1LdeaEv+ZKqiw3V_DCfqjRw@mail.gmail.com>
	 <1350246314.21172.17139.camel@edumazet-glaptop>
	 <1350246414.21172.17144.camel@edumazet-glaptop>
	 <1350246481.21172.17147.camel@edumazet-glaptop>
	 <CAO_aot5xZevtZcCS37h9HR4Zkj_Q4ny_sj+NX7oYEvazAQjxLQ@mail.gmail.com>
	 <1350247546.21172.17167.camel@edumazet-glaptop>
	 <1350247678.21172.17170.camel@edumazet-glaptop>
	 <CAO_aot5eyNmYhMi7LSKqwsb=hFbWUqOF3rzWt7Kt-C4hJ9pOmQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Jan Hinnerk Stosch <janhinnerk.stosch@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:36704 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754399Ab2JNVCe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 14 Oct 2012 17:02:34 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1006690eaa.19
        for <netdev@vger.kernel.org>; Sun, 14 Oct 2012 14:02:33 -0700 (PDT)
In-Reply-To: <CAO_aot5eyNmYhMi7LSKqwsb=hFbWUqOF3rzWt7Kt-C4hJ9pOmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-10-14 at 22:56 +0200, Jan Hinnerk Stosch wrote:
> 2012/10/14 Eric Dumazet <eric.dumazet@gmail.com>:
> > On Sun, 2012-10-14 at 22:45 +0200, Eric Dumazet wrote:
> >
> >> OK so IPv6 UDP frames are delivered to ntpd
> >>
> >> could you strace it while doing one "ntpq -p"
> >>
> >> strace -p 368
> >>
> >
> > Also please post "ip -6 addr"
> >
> >
> 
> ip -6 addr gives:
> 1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436
>     inet6 ::1/128 scope host
>        valid_lft forever preferred_lft forever
> 2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qlen 1000
>     inet6 fe80::922b:34ff:fe33:c292/64 scope link
>        valid_lft forever preferred_lft forever
> 
> And the output of "strace ntpq -p" is attached in file "ntpq-p".
> 
> I also did a tcpdump earlier this day as told in the bugtracker. Find
> the parts containing "ntpd" attached in file "tcpdump".

I already got these files, thank you

I asked a strace of the ntpd daemon, since we now know frames are
delivered to the application. I want to check what ntpd does of these
frames, since apparently it gives no answer.
