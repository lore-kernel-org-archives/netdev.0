From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Netperf UDP issue with connected sockets
Date: Thu, 17 Nov 2016 06:17:38 -0800
Message-ID: <1479392258.8455.249.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20140903165943.372b897b@redhat.com>
         <1409757426.26422.41.camel@edumazet-glaptop2.roam.corp.google.com>
         <20161116131609.4e5726b4@redhat.com>
         <7c4b43a4-74bf-1ee2-6f0d-17783b5d8fcb@hpe.com>
         <20161116234022.2bad179b@redhat.com>
         <1479342849.8455.233.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117091638.5fab8494@redhat.com>
         <1479388850.8455.240.camel@edumazet-glaptop3.roam.corp.google.com>
         <20161117144248.23500001@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Rick Jones <rick.jones2@hpe.com>, netdev@vger.kernel.org
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f54.google.com ([74.125.83.54]:34273 "EHLO
        mail-pg0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754753AbcKQRX3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Nov 2016 12:23:29 -0500
Received: by mail-pg0-f54.google.com with SMTP id x23so90775498pgx.1
        for <netdev@vger.kernel.org>; Thu, 17 Nov 2016 09:23:29 -0800 (PST)
In-Reply-To: <20161117144248.23500001@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-11-17 at 14:42 +0100, Jesper Dangaard Brouer wrote:

> I can see that qdisc layer does not activate xmit_more in this case.
> 

Sure. Not enough pressure from the sender(s).

The bottleneck is not the NIC or qdisc in your case, meaning that BQL
limit is kept at a small value.

(BTW not all NIC have expensive doorbells)
