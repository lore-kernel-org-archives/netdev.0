From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net/gtp: Add udp source port generation
 according to flow hash
Date: Thu, 23 Feb 2017 12:01:24 -0500 (EST)
Message-ID: <20170223.120124.846549814513489060.davem@davemloft.net>
References: <20170223140012.GA4462@salvia>
        <CALx6S37QT-3W5psz0f2bf+RTzt09AysCtwTQmzZsHS_g6uo5ZA@mail.gmail.com>
        <20170223165051.c3jlvht4mhsuoxmq@nataraja>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tom@herbertland.com, pablo@netfilter.org, aschultz@tpip.net,
        gerlitz.or@gmail.com, ogerlitz@mellanox.com, jhs@mojatatu.com,
        netdev@vger.kernel.org, timo.lindhorst@travelping.com
To: laforge@gnumonks.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46258 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751049AbdBWRhd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2017 12:37:33 -0500
In-Reply-To: <20170223165051.c3jlvht4mhsuoxmq@nataraja>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Harald Welte <laforge@gnumonks.org>
Date: Thu, 23 Feb 2017 17:50:51 +0100

> I understand and support the motivation to design robust systsems even
> in the presence of broken/ignorant specs, but I think this is one of the
> situations where it is useless (and IMHO impossible) to do anything
> about it.

I think avoiding trying to do something reasonable about this and just
saying "this is how cellular networks are" is not acceptable.

We know how to properly strengthen tunnelling implementations in the
kernel against DDoS attachs, GTP can be treated similarly.
