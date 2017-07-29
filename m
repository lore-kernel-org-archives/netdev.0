From: David Miller <davem@davemloft.net>
Subject: Re: [RFC PATCH v1 5/5] wave: Added basic version of TCP Wave
Date: Fri, 28 Jul 2017 18:52:08 -0700 (PDT)
Message-ID: <20170728.185208.821362205555741040.davem@davemloft.net>
References: <20170728195919.10099-1-natale.patriciello@gmail.com>
        <20170728195919.10099-6-natale.patriciello@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org, ahmed.said@uniroma2.it,
        zampognaro@ing.uniroma2.it, roseti@ing.uniroma2.it
To: natale.patriciello@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57566 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753159AbdG2BwJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 21:52:09 -0400
In-Reply-To: <20170728195919.10099-6-natale.patriciello@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Natale Patriciello <natale.patriciello@gmail.com>
Date: Fri, 28 Jul 2017 21:59:19 +0200

> +static __always_inline bool test_flag(u8 value, const u8 *flags)

Never, ever, declare functions as inline in foo.c files.

Always let the compiler decide.  No matter how brilliant you think
you are, it always knows better.

And when it doesn't, that's a bug that should be fixed instead of
worked around in our code.

Thanks.
