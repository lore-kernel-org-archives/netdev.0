From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [WIP] net+mlx4: auto doorbell
Date: Wed, 30 Nov 2016 09:28:30 -0800
Message-ID: <1480526910.18162.193.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
         <20161116131609.4e5726b4@redhat.com>
         <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
         <20161116234022.2bad179b@redhat.com>
         <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117091638.5fab8494@redhat.com>
         <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
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
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        Rick Jones <rick.jones2@hpe.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        Saeed Mahameed <saeedm@mellanox.com>,
        Tariq Toukan <tariqt@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:33245 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1161056AbcK3R3d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 12:29:33 -0500
Received: by mail-pg0-f67.google.com with SMTP id 3so1898742pgd.0
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 09:29:32 -0800 (PST)
In-Reply-To: <CALzJLG9iCWkk2WTGrkFhZ61Sx5R-JDCxANhLQZPO8E47QGwOmQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-11-30 at 18:27 +0200, Saeed Mahameed wrote:

> 
> In this case, i think they should implement their own bulking (pktgen
> is not a good example)
> but XDP can predict if it has more packets to xmit  as long as all of
> them fall in the same NAPI cycle.


> Others should try and do the same.

We can not trust user space to signal us when it is the good time to
perform a doorbell.

trafgen is using af_packet with qdisc bypass for example.
