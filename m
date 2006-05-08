From: "Wong Edison" <hswong3i@gmail.com>
Subject: Re: [PATCH] TCP congestion module: add TCP-LP supporting for 2.6.16.14
Date: Tue, 9 May 2006 01:25:45 +0800
Message-ID: <3feffd230605081025t6fa078abm5c610b9a597a1ca@mail.gmail.com>
References: <3feffd230605062232m1b9a3951h6d21071cdacc890f@mail.gmail.com>
	 <20060508112915.GB4162@ucw.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
	format=flowed
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.178]:14624 "EHLO
	py-out-1112.google.com") by vger.kernel.org with ESMTP
	id S932462AbWEHRZr convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 May 2006 13:25:47 -0400
Received: by py-out-1112.google.com with SMTP id f28so1348757pyf
        for <netdev@vger.kernel.org>; Mon, 08 May 2006 10:25:46 -0700 (PDT)
To: "Pavel Machek" <pavel@suse.cz>
In-Reply-To: <20060508112915.GB4162@ucw.cz>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

umum...
as i am new in submitting patch...
althought i have already read for a lot of reference...
i know only a little about the format required :(

i would like to do whatever i need to do
may u give me some hints about how to do so ??

net-nice -n 19 rsync ??
sorry that i don't know what is it... :(

for how to use it
1. patch the source tree
2. chose TCP-LP as modules and make it
3. after install use:
  sysctl -w net.ipv4.tcp_congestion_control=lp
4. you will then find your connection is relatively lower priority
than other computers

i put my work in my site:
http://edin.no-ip.com/project/tcp-lp/

Regard,
Edison

2006/5/8, Pavel Machek <pavel@suse.cz>:
> Hi!
>
> > TCP Low Priority is a distributed algorithm whose goal
> > is to utilize only
> > the excess network bandwidth as compared to the ``fair
> > share`` of
> > bandwidth as targeted by TCP. Available from:
> >   http://www.ece.rice.edu/~akuzma/Doc/akuzma/TCP-LP.pdf
>
> Nice... I'd like to use something like this on my (overloaded)
> GPRS/EDGE link.
>
> Unfortunately, patch does not include documentation update AFAICS. How
> do I use it? net-nice -n 19 rsync would be nice, but I guess that
> would be quite complex...?
>                                                         Pavel
> --
> Thanks for all the (sleeping) penguins.
>
