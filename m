From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Requeues and ECN marking
Date: Mon, 03 Feb 2014 09:59:20 -0800
Message-ID: <1391450360.28432.104.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAMvx-beWMC8awScfEtHs8sSkzz0fGNqBH1fn7hC=k0iaFpJvSA@mail.gmail.com>
	 <1391448503.28432.101.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMvx-bccJce7U4=KAO-uaot8uguORtBK0kPxdFUUgDkNWJVmMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Greg Kuperman <gregk@MIT.EDU>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f49.google.com ([209.85.160.49]:41280 "EHLO
	mail-pb0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752160AbaBCR7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Feb 2014 12:59:21 -0500
Received: by mail-pb0-f49.google.com with SMTP id up15so7334056pbc.36
        for <netdev@vger.kernel.org>; Mon, 03 Feb 2014 09:59:21 -0800 (PST)
In-Reply-To: <CAMvx-bccJce7U4=KAO-uaot8uguORtBK0kPxdFUUgDkNWJVmMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-02-03 at 12:48 -0500, Greg Kuperman wrote:

> I am running RED queuing discipline on the egress of node 1 with the
> following setup:
> tc qdisc add dev eth1 root red burst 1000000 limit 10000000 avpkt 1000
> ecn bandwidth 125 probability 1

But these parameters are huge, and you get what you asked for.

burst=1000000, and avpkt=1000 means you have to queue more than 1000
packets before red being active, and marking packets eventually (or drop
them if non ECN capable)

Even probability=1 makes little sense.

Please read http://linux.die.net/man/8/tc-red for some guidance.
