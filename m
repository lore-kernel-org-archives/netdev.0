From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: diag: fix a potential security issue
Date: Sat, 21 Oct 2017 12:14:10 +0100 (WEST)
Message-ID: <20171021.121410.701233686946304734.davem@davemloft.net>
References: <cover.1508398111.git.lucien.xin@gmail.com>
        <20171021.022737.1906342496133825805.davem@davemloft.net>
        <CADvbK_fWmmC3ggpoT--Pxk3GxZ8Gq_rbdFGTuXk-BuTHTO=eXw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com,
        marcelo.leitner@gmail.com, sd@queasysnail.net
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50406 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932067AbdJULOQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 21 Oct 2017 07:14:16 -0400
In-Reply-To: <CADvbK_fWmmC3ggpoT--Pxk3GxZ8Gq_rbdFGTuXk-BuTHTO=eXw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Sat, 21 Oct 2017 14:06:27 +0800

> Imagine a customer generates a sosreport on their system, and
> with that, it loads sctp module. From then on, if their firewall
> doesn't block incoming packets for sctp, they may be prone to some
> remotely triggerable issue on sctp code, without even actually using
> sctp.

Like I said, if the protocol is so unsafe, block it in the
modules.conf file.

Block all "I don't use this" protocols in netfilter.

Otherwise, like I said, any user on their system can open a socket of
the indicated protocol.

There are many options.

Furthermore, "ss" should not signal an error because the protocol
module happens to not be open yet and as I understand it this is what
your patch does since it chooses to not load the module in this
situation.
