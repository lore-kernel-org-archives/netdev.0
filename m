From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Mon, 21 Aug 2017 10:44:13 -0700
Message-ID: <1503337453.2499.7.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
         <CAA5aLPgekZJgsZV-MAD+F+ggUugQkz12D9Ef=kbP9Ev=Q1QsDw@mail.gmail.com>
         <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
         <1502969805.4936.154.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
         <063D6719AE5E284EB5DD2968C1650D6DD005C7B1@AcuExch.aculab.com>
         <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
         <1503328678.2499.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPhtK8YbSDua-F16C0W9fLm2w4=ta4g+Tv+wsUEqYPCxUg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:35762 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754072AbdHURoP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 13:44:15 -0400
Received: by mail-pg0-f54.google.com with SMTP id u191so29365936pgc.2
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 10:44:14 -0700 (PDT)
In-Reply-To: <CAA5aLPhtK8YbSDua-F16C0W9fLm2w4=ta4g+Tv+wsUEqYPCxUg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-21 at 22:58 +0530, Akshat Kakkar wrote:

> As mentioned in my initial description, the server is not sending
> SYN-ACK. Thats what the main symptom. For completeness, its not
> sending any RST also.
> However, if I disable TCP timestamp ... the server starts giving SYN-ACK.
> The strangest thing is, my client doesnt initiate a connection with
> tcp timestamp, so how come disabling tcp timestamp is making things
> work.

As I said, maybe the bug was already fixed months ago.

By running an old kernel, you want us to spend time on something that
might already have been fixed.

Only if you run a current kernel _and_ reproduce the problem, then we
might take a look.

I suspect your client is a single host ?

- Why is timewait not being used ?

- What sysctls have been changed on your server ?
