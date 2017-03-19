From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Sun, 19 Mar 2017 13:14:17 +0100
Message-ID: <20170319121417.GA293@x4>
References: <20170202123427.GA7212@x4>
 <1486042270.13103.26.camel@edumazet-glaptop3.roam.corp.google.com>
 <1486043964.13103.33.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170203115457.GA5296@localhost.localdomain>
 <1486128246.21871.83.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170203135355.GA3413@localhost.localdomain>
 <1486131366.21871.87.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170203142828.GB3413@localhost.localdomain>
 <1486133253.21871.89.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170206211226.GC3413@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ud10.udmedia.de ([194.117.254.50]:51566 "EHLO
        mail.ud10.udmedia.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751562AbdCSMPE (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 19 Mar 2017 08:15:04 -0400
Content-Disposition: inline
In-Reply-To: <20170206211226.GC3413@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2017.02.06 at 19:12 -0200, Marcelo Ricardo Leitner wrote:
> On Fri, Feb 03, 2017 at 06:47:33AM -0800, Eric Dumazet wrote:
> > On Fri, 2017-02-03 at 12:28 -0200, Marcelo Ricardo Leitner wrote:
> > 
> > > Aren't you mixing the endpoints here? MSS is the largest amount of data
> > > that the peer can receive in a single segment, and not how much it will
> > > send. For the sending part, that depends on what the other peer
> > > announced, and we can have 2 different MSS in a single connection, one
> > > for each peer.
> > > 
> > > If a peer later wants to send larger segments, it can, but it must
> > > respect the mss advertised by the other peer during handshake.
> > > 
> > 
> > I am not mixing endpoints, you are.
> > 
> > If you need to be convinced, please grab :
> > https://patchwork.ozlabs.org/patch/723028/
> > 
> > And just watch "ss -temoi ..." 
> 
> I still don't get it, but I also hit the warning on my laptop, using
> iwlwifi. Not sure what I did in order to trigger it, it was by accident.

After many weeks without any warning, I've hit the issue again today:

 TCP: eth0: Driver has suspect GRO implementation, TCP performance may be compromised. rcv_mss:1448 advmss:1448 len:1460

-- 
Markus
