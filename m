From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Something hitting my total number of connections to the server
Date: Tue, 22 Aug 2017 10:50:42 -0700
Message-ID: <1503424242.2499.40.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CAA5aLPic9U4cwFJuTd4qBZrV=oVUSfmPzVRR_jXOBpJMU11b0A@mail.gmail.com>
         <1502879661.4936.98.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPh0m=ZZp5kcz9h3if8kemg0QRykBpfYAnr6Bd1ptoeKKg@mail.gmail.com>
         <1502969805.4936.154.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPjs2S0cV7MoYLB6MvZVKXomUmwpi=EVHDXh=AwR_xBqsw@mail.gmail.com>
         <063D6719AE5E284EB5DD2968C1650D6DD005C7B1@AcuExch.aculab.com>
         <CAA5aLPhVSnJkGNtwEeswbPnhT_RdJewAKDs-pJOUzTPEpwkUAA@mail.gmail.com>
         <1503328678.2499.3.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPhtK8YbSDua-F16C0W9fLm2w4=ta4g+Tv+wsUEqYPCxUg@mail.gmail.com>
         <1503337453.2499.7.camel@edumazet-glaptop3.roam.corp.google.com>
         <1503337498.2499.8.camel@edumazet-glaptop3.roam.corp.google.com>
         <CAA5aLPgtfrA053gAbsXOZTdrJKtsOZODUmF5cPGmnOmsO3PbOA@mail.gmail.com>
         <1503406926.2499.20.camel@edumazet-glaptop3.roam.corp.google.com>
         <bf580154-aea9-4143-5d9c-df3764b5e745@gmail.com>
         <1503423863.2499.39.camel@edumazet-glaptop3.roam.corp.google.com>
         <724144b0-ba06-9d10-56d5-24e22c574506@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Akshat Kakkar <akshat.1984@gmail.com>,
        David Laight <David.Laight@aculab.com>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:36754 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751910AbdHVRun (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:50:43 -0400
Received: by mail-pf0-f169.google.com with SMTP id c28so26463184pfe.3
        for <netdev@vger.kernel.org>; Tue, 22 Aug 2017 10:50:43 -0700 (PDT)
In-Reply-To: <724144b0-ba06-9d10-56d5-24e22c574506@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-08-22 at 10:46 -0700, David Ahern wrote:
> On 8/22/17 10:44 AM, Eric Dumazet wrote:
> > Willem wrote this doc in 2013, before we finally went back to 1000.
> > 
> > We should update this doc.
> 
> 
> And these too:
> 
> $ egrep -r netdev_max_backlog Documentation/networking/
> Documentation/networking//cxgb.txt:      sysctl -w
> net.core.netdev_max_backlog=300000
> Documentation/networking//ixgb.txt:net.core.netdev_max_backlog = 300000

Yes, whoever wrote this had no idea of the implications I guess.
