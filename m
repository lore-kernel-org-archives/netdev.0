From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: "TCP: eth0: Driver has suspect GRO implementation, TCP
 performance may be compromised." message with "ethtool -K eth0 gro off"
Date: Fri, 03 Feb 2017 06:47:33 -0800
Message-ID: <1486133253.21871.89.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20170202115240.GH17590@x4>
         <1486038733.13103.21.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170202123427.GA7212@x4>
         <1486042270.13103.26.camel@edumazet-glaptop3.roam.corp.google.com>
         <1486043964.13103.33.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170203115457.GA5296@localhost.localdomain>
         <1486128246.21871.83.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170203135355.GA3413@localhost.localdomain>
         <1486131366.21871.87.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170203142828.GB3413@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Markus Trippelsdorf <markus@trippelsdorf.de>,
        netdev@vger.kernel.org
To: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34084 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751958AbdBCOrf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 09:47:35 -0500
Received: by mail-pg0-f67.google.com with SMTP id v184so2164861pgv.1
        for <netdev@vger.kernel.org>; Fri, 03 Feb 2017 06:47:35 -0800 (PST)
In-Reply-To: <20170203142828.GB3413@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-02-03 at 12:28 -0200, Marcelo Ricardo Leitner wrote:

> Aren't you mixing the endpoints here? MSS is the largest amount of data
> that the peer can receive in a single segment, and not how much it will
> send. For the sending part, that depends on what the other peer
> announced, and we can have 2 different MSS in a single connection, one
> for each peer.
> 
> If a peer later wants to send larger segments, it can, but it must
> respect the mss advertised by the other peer during handshake.
> 

I am not mixing endpoints, you are.

If you need to be convinced, please grab :
https://patchwork.ozlabs.org/patch/723028/

And just watch "ss -temoi ..." 
