From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 6/6] bpf: show bpf programs
Date: Thu, 27 Apr 2017 12:00:19 -0400 (EDT)
Message-ID: <20170427.120019.1559603500876505216.davem@davemloft.net>
References: <20170426182419.14574-7-hannes@stressinduktion.org>
        <590112BE.7040902@iogearbox.net>
        <5b1f23e3-86a7-69aa-91e2-1dc72125f22b@stressinduktion.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: daniel@iogearbox.net, netdev@vger.kernel.org, ast@kernel.org,
        daniel@iogearbox.com, jbenc@redhat.com, aconole@bytheb.org
To: hannes@stressinduktion.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42438 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S939198AbdD0QAj (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 27 Apr 2017 12:00:39 -0400
In-Reply-To: <5b1f23e3-86a7-69aa-91e2-1dc72125f22b@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Date: Thu, 27 Apr 2017 15:22:49 +0200

> Sure, that sounds super. But so far Linux and most (maybe I should write
> all) subsystems always provided some easy way to get the insights of the
> kernel without having to code or rely on special tools so far.

Not true.

You cannot fully dump socket TCP internal state without netlink based
tools.  It is just one of many examples.

Can you dump all nftables rules without a special tool?

I don't think this is a legitimate line of argument, and I want
this to be done via the bpf() system call which is what people
are working on.

Thanks.
