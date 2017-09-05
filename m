From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [pull request][net-next 0/3] Mellanox, mlx5 GRE tunnel offloads
Date: Tue, 05 Sep 2017 13:14:10 +0200
Message-ID: <87r2vls8hp.fsf@stressinduktion.org>
References: <20170830230409.15176-1-saeedm@mellanox.com>
        <87fuc7ong0.fsf@stressinduktion.org>
        <CALzJLG-u3k11LYFXtZQKT5cvn-iJ4FehBUgkhCHT5Z7XMsMkpA@mail.gmail.com>
        <1504402349.3299394.1093467800.72B91372@webmail.messagingengine.com>
        <CALx6S34kfb5GEH9AAecsaKJ9AtjK=fP_3L=2i98kUwv_sE2s7A@mail.gmail.com>
        <CALzJLG--t8VLs1GiRRVfejenB=XgpLiJHnHC+eokQ4=kwj9hGw@mail.gmail.com>
        <CALx6S356vRYfcsN6FaRmpn2oC0GN9-JwLsF7ybC+w4sEGGsa7w@mail.gmail.com>
        <87pob6bmjv.fsf@stressinduktion.org>
        <CALx6S37wcp1om0Dwr1=-6jF=HkAuZj313pLJ7sVhgsyJ4yZDjg@mail.gmail.com>
        <8760cytnif.fsf@stressinduktion.org>
        <CALx6S34cOL4Gy9DMWnLV0iCVUYo+siMEeNNn9v5tBHr2P6yjYw@mail.gmail.com>
        <87k21ez6r9.fsf@stressinduktion.org>
        <CALx6S34aDER1Gzpcw+p7+yr91mjiixCh6gnawKSxy7zhVQz+6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
        Saeed Mahameed <saeedm@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:56071 "EHLO
        out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750755AbdIELON (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 07:14:13 -0400
In-Reply-To: <CALx6S34aDER1Gzpcw+p7+yr91mjiixCh6gnawKSxy7zhVQz+6Q@mail.gmail.com>
        (Tom Herbert's message of "Mon, 4 Sep 2017 11:56:00 -0700")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert <tom@herbertland.com> writes:

> There is absolutely no requirement in IP that packets are delivered in
> order-- there never has been and there never will be! If the ULP, like
> Ethernet encapsulation, requires in order deliver then it needs to
> implement that itself like TCP, GRE, and other protocols ensure that
> with sequence numbers and reassembly. All of these hoops we do make
> sure that packets always follow the same path and are always in order
> are done for benefit of middlebox devices like stateful firewalls that
> have force us to adopt their concept of network architecture-- in the
> long run this is self-defeating and kills our ability to innovate.
>
> I'm not saying that we shouldn't consider legacy devices, but we
> should scrutinize new development or solutions that perpetuate
> incorrect design or bad assumptions.

So configure RSS per port and ensure no fragments are send to those
ports. This is possible and rather easy to do. It solves the problem
with legacy software and it spreads out packets for your applications.

It is not perfect but it is working and solves both problems.

Bye,
Hannes
