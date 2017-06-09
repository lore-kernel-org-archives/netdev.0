From: Petr Machata <petrm@mellanox.com>
Subject: Re: [PATCH] net: vrf: Make add_fib_rules per network namespace flag
Date: Fri, 09 Jun 2017 13:09:31 +0200
Message-ID: <87shj92z9w.fsf@mellanox.com>
References: <20170608173111.22831-1-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db5eur01on0052.outbound.protection.outlook.com ([104.47.2.52]:34064
        "EHLO EUR01-DB5-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751530AbdFILJl (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 9 Jun 2017 07:09:41 -0400
In-Reply-To: <20170608173111.22831-1-dsahern@gmail.com> (David Ahern's message
        of "Thu, 8 Jun 2017 11:31:11 -0600")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Ahern <dsahern@gmail.com> writes:

> Commit 1aa6c4f6b8cd8 ("net: vrf: Add l3mdev rules on first device create")
> adds the l3mdev FIB rule the first time a VRF device is created. However,
> it only creates the rule once and only in the namespace the first device
> is created - which may not be init_net. Fix by using the net_generic
> capability to make the add_fib_rules flag per network namespace.

Works per my testing.

Thanks!
Petr
