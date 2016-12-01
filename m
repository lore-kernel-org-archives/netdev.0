From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Thu, 01 Dec 2016 12:11:26 -0800
Message-ID: <1480623086.18162.329.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <20161117144248.23500001@redhat.com>
         <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117155753.17b76f5a@redhat.com>
         <1479399679.8455.255.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117193021.580589ae@redhat.com>
         <1479408683.8455.273.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161121170351.50a09ee1@redhat.com>
         <1479751857.8455.419.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480402716.18162.124.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG_G3G-_jFFD0xiAOfR-k69rhb_2ia4LHZroE-oEFxApnQ@mail.gmail.com>
         <1480520661.18162.177.camel@edumazet-glaptop3.roam.corp.google.com>
         <CALzJLG9iCWkk2WTGrkFhZ61Sx5R-JDCxANhLQZPO8E47QGwOmQ@mail.gmail.com>
         <20161201130505.0b4a5cd5@redhat.com>
         <1480602274.18162.285.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161201170443.28a8c032@redhat.com>
         <1480611857.18162.319.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161201201707.5f51a02e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Rick Jones <rick.jones2@hpe.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:36691 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750975AbcLAUM3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 15:12:29 -0500
Received: by mail-pg0-f68.google.com with SMTP id x23so5552120pgx.3
        for <netdev@vger.kernel.org>; Thu, 01 Dec 2016 12:12:29 -0800 (PST)
In-Reply-To: <20161201201707.5f51a02e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-12-01 at 20:17 +0100, Jesper Dangaard Brouer wrote:
> On Thu, 01 Dec 2016 09:04:17 -0800 Eric Dumazet <eric.dumazet@gmail.com> wrote:
> 
> > BTW, if you are doing tests on mlx4 40Gbit,
> 
> I'm mostly testing with mlx5 50Gbit, but I do have 40G NIC in the
> machines too.
> 
> >  would you check the
> > following quick/dirty hack, using lots of low-rate flows ?
> 
> What tool should I use to send "low-rate flows"?
> 

You could use https://github.com/google/neper

It supports SO_MAX_PACING_RATE, and you could launch 1600 flows, rate
limited to 3028000 bytes per second  (so sending one 2-MSS TSO packet
every ms per flow)



> And what am I looking for?

Max throughput, in packets per second :/
