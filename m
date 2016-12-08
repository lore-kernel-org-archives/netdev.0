From: Paolo Abeni <pabeni@redhat.com>
Subject: Re: [PATCH net-next] net: sock_rps_record_flow() is for connected
 sockets
Date: Thu, 08 Dec 2016 18:49:58 +0100
Message-ID: <1481219398.6120.1.camel@redhat.com>
References: <1480905784.18162.509.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480944138.4694.37.camel@redhat.com>
         <1480948133.18162.527.camel@edumazet-glaptop3.roam.corp.google.com>
         <1480960639.18162.556.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481020451.6225.38.camel@redhat.com> <1481044098.7129.7.camel@redhat.com>
         <1481046434.18162.599.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481049061.7129.18.camel@redhat.com>
         <1481050715.18162.604.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481051786.7129.22.camel@redhat.com>
         <1481052922.18162.605.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481081570.18162.626.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481093247.18162.637.camel@edumazet-glaptop3.roam.corp.google.com>
         <1481097428.5535.12.camel@redhat.com>
         <1481120791.4930.4.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
        netdev <netdev@vger.kernel.org>,
        Willem de Bruijn <willemb@google.com>,
        Tom Herbert <tom@herbertland.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:41452 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751932AbcLHRuC (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Dec 2016 12:50:02 -0500
In-Reply-To: <1481120791.4930.4.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2016-12-07 at 06:26 -0800, Eric Dumazet wrote:
> On Wed, 2016-12-07 at 08:57 +0100, Paolo Abeni wrote:
> > On Tue, 2016-12-06 at 22:47 -0800, Eric Dumazet wrote:
> > > On Tue, 2016-12-06 at 19:32 -0800, Eric Dumazet wrote:
> > > > A follow up patch will provide a static_key (Jump Label) since most
> > > > hosts do not even use RFS.
> > > 
> > > Speaking of static_key, it appears we now have GRO on UDP, and this
> > > consumes a considerable amount of cpu cycles.
> > > 
> > > Turning off GRO allows me to get +20 % more packets on my single UDP
> > > socket. (1.2 Mpps instead of 1.0 Mpps)
> > 
> > I see also an improvement for single flow tests disabling GRO, but on a
> > smaller scale (~5% if I recall correctly).
> 
> Was it on a NUMA host ?

I'm using a single socket host, with 12 cores/24 threads and 16 RX
queues. 
But my data is old. I'll re-run the test on top of current net-next.

Paolo
