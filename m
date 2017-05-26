From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net/sched: let chain_get to figure out the
 return value
Date: Fri, 26 May 2017 10:59:12 -0400 (EDT)
Message-ID: <20170526.105912.229870645071385383.davem@davemloft.net>
References: <20170526072129.11075-1-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        mlxsw@mellanox.com
To: jiri@resnulli.us
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41120 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S936350AbdEZO7O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 10:59:14 -0400
In-Reply-To: <20170526072129.11075-1-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jiri Pirko <jiri@resnulli.us>
Date: Fri, 26 May 2017 09:21:29 +0200

> From: Jiri Pirko <jiri@mellanox.com>
> 
> Alhough I believe that this create/nocreate dance is completelly
> pointless, at least make it a bit nicer and easier to read.
> Push the decision on what error value is returned to chain_get function
> and use ERR macros.
> 
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>

No, this is quite worse.

You're leaving pointer error values in structures.  That's extremely
error prone.

And as stated in the other thread, I don't think Cong's logic is strange
or hard to understand at all.
