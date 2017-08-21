From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Mon, 21 Aug 2017 08:17:58 -0700
Message-ID: <1503328678.2499.3.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
         <CAA5aLPgekZJgsZV-MAD+F+ggUugQkz12D9Ef=kbP9Ev=Q1QsDw@mail.gmail.com>
         <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
         <1502969805.4936.154.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
         <063D6719AE5E284EB5DD2968C1650D6DD005C7B1@AcuExch.aculab.com>
         <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>
To: Akshat Kakkar <akshat.1984@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34961 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753222AbdHUPSA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 21 Aug 2017 11:18:00 -0400
Received: by mail-pg0-f54.google.com with SMTP id u191so27355474pgc.2
        for <netdev@vger.kernel.org>; Mon, 21 Aug 2017 08:18:00 -0700 (PDT)
In-Reply-To: <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-08-21 at 15:26 +0530, Akshat Kakkar wrote:
> On Mon, Aug 21, 2017 at 3:13 PM, David Laight <David.Laight@aculab.com> wrote:
> > From: Akshat Kakkar
> >> Sent: 18 August 2017 10:14
> >> On Thu, Aug 17, 2017 at 5:06 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> >> > On Thu, 2017-08-17 at 14:35 +0530, Akshat Kakkar wrote:
> >> >
> >> >> I upgraded to 4.4 but still experiencing same issue.
> >> >> Please help.
> >> >
> >> > Still too old kernel, shoot again ;)
> >> >
> >> >
> >>
> >>
> >> Sorry but that's the maximum I can try as of now as its the LT version.
> >
> > You should be able to build a current kernel and run it with your
> > existing user space.
> >
> >         David
> >
> 
> The issue is with tcp timestamp. When I am disabling it, things are
> working fine but when I enable the issue re-occurs. However, I am not
> seeing tcp timestamps on packet, even when it is enabled simply
> because my client doesn't support it.
> 
> But the question is, if I my client doesnt support timestamp , why
> enabling timestamp on server side is creating an issue??

Maybe you changed some sysctls wrongly ?
