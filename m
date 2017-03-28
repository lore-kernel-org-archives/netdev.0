From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: Re: [Outreachy kernel] [PATCH] net: netfilter: Remove complexity
Date: Tue, 28 Mar 2017 17:26:07 +0200
Message-ID: <20170328152607.GA1735@salvia>
References: <20170328130032.GA5009@arushi-HP-Pavilion-Notebook>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jozsef Kadlecsik <kadlec@blackhole.kfki.hu>, davem@davemloft.net,
        netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
        linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
        outreachy-kernel@googlegroups.com
To: Arushi Singhal <arushisinghal19971997@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:46790 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751476AbdC1P0U (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 28 Mar 2017 11:26:20 -0400
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id F1AD252437
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 17:26:10 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id DAC47B7FE7
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 17:26:10 +0200 (CEST)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 69F8BBAAD5
        for <netdev@vger.kernel.org>; Tue, 28 Mar 2017 17:26:07 +0200 (CEST)
Content-Disposition: inline
In-Reply-To: <20170328130032.GA5009@arushi-HP-Pavilion-Notebook>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 28, 2017 at 06:30:56PM +0530, Arushi Singhal wrote:
> To remove complexity of code the function is added in nfnetlink.h
> to make code more clear and readable.

Patch looks good, you can also use this new function from other
_fill_info() functions in the netfilter code, eg.

        nfnl_cthelper_fill_info()

Take the time to make a careful look at the netfilter tree to see if
we can have a good bunch of new clients of this function in one go.
Most likely many of the nfnetlink_*.c files can use this.

BTW, you can also indicate in your patch description that this is
opencoded in a way that makes it error prone for future netfilter
netlink subsystems.

Please search for a better patch title, this one is too generic. I
understand selecting a good patch title is something that exercise.

I'd suggest this:

        netfilter: add nfnl_msg_type() helper function

Never give up, revamp and resubmit, thanks!
