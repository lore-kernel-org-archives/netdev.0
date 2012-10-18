From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: listen(2) backlog changes in or around Linux 3.1?
Date: Thu, 18 Oct 2012 18:54:00 +0200
Message-ID: <1350579240.32642.62.camel@edumazet-glaptop>
References: <CAJgzZorigejCuFweNrvmkEJts3Um7exh1fYTH=4KrEcB=v=2SA@mail.gmail.com>
	 <507C4401.7050500@oracle.com>
	 <CAJgzZoqhw6HJxa6uRbekLMaVTDVOo92YDtzqHnZoRiQ8tq6G2g@mail.gmail.com>
	 <CAJgzZoq9+KZpQ1tVQJUK++VVk4JfY9u8timaJ5q6wSYoF+_tog@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: enh <enh@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:49150 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757162Ab2JRQyF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Oct 2012 12:54:05 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so2240022eaa.19
        for <netdev@vger.kernel.org>; Thu, 18 Oct 2012 09:54:03 -0700 (PDT)
In-Reply-To: <CAJgzZoq9+KZpQ1tVQJUK++VVk4JfY9u8timaJ5q6wSYoF+_tog@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-16 at 16:31 -0700, enh wrote:
> boiling things down to a short C++ program, i see that i can reproduce
> the behavior even on 2.6 kernels. if i run this, i see 4 connections
> immediately (3 + 1, as i'd expect)... but then about 10s later i see
> another 2. and every few seconds after that, i see another 2. i've let
> this run until i have hundreds of connect(2) calls that have returned,
> despite my small listen(2) backlog and the fact that i'm not
> accept(2)ing.
> 
> so i guess the only thing that's changed with newer kernels is timing
> (hell, since i only see newer kernels on newer hardware, it might just
> be a hardware thing).
> 
> and clearly i don't understand what the listen(2) backlog means any more.


Hi Elliott

I would say there is a bug (or several !!), and this needs a fix.

I am investigating.

Thanks
