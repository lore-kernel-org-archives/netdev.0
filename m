From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3 net-next 3/4] sctp: add support for generating stream
 reconf add incoming/outgoing streams request chunk
Date: Mon, 23 Jan 2017 11:00:47 -0500 (EST)
Message-ID: <20170123.110047.447365739282173577.davem@davemloft.net>
References: <20170120163921.GU3781@localhost.localdomain>
        <063D6719AE5E284EB5DD2968C1650D6DB026B8E0@AcuExch.aculab.com>
        <20170123123628.GX3781@localhost.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David.Laight@ACULAB.COM, lucien.xin@gmail.com,
        netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        nhorman@tuxdriver.com, vyasevich@gmail.com
To: marcelo.leitner@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750705AbdAWQAt (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 23 Jan 2017 11:00:49 -0500
In-Reply-To: <20170123123628.GX3781@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "'Marcelo Ricardo Leitner'" <marcelo.leitner@gmail.com>
Date: Mon, 23 Jan 2017 10:36:28 -0200

> So, no padding. A field just after the other, which is what we want on a
> network header.

It isn't necessary!

Show me a case where it is required when you use properly fixed sized
types and a proper ordering of the struct members.  No padding is
going in there, go and check.

Do we splatter __packed all over our ipv4/ipv6 header, TCP header, UDP
header, etc. structures?  No, we don't because it's totally unecessary.

I will not accept __packed being used unless it is absolutely, provably,
the only way to solve a particular problem.  And when that does happen,
I am going to require a huge comment explaining in detail why this is
the case, and why no other approach or solution solved the problem.
