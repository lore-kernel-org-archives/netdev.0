From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next V2 0/3] net/sched: act_pedit: Use offset
 relative to conventional network headers
Date: Fri, 06 Jan 2017 20:51:09 -0500 (EST)
Message-ID: <20170106.205109.917848391545129035.davem@davemloft.net>
References: <20170105095454.32644-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jiri@mellanox.com, ogerlitz@mellanox.com,
        hadarh@mellanox.com
To: amir@vadai.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:49568 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1162590AbdAGBvU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 6 Jan 2017 20:51:20 -0500
In-Reply-To: <20170105095454.32644-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>
Date: Thu,  5 Jan 2017 11:54:51 +0200

> Enhancing the UAPI to allow for specifying that would allow the same
> flows to be set into both SW and HW.

This is actually not backward compatible.

When pedit rules are dumped, older tools will not know about the
type field and therefore will completely misinterpret the rule.

You must extend this the proper way, which is to add a new attribute
or something along those lines.  The presense of a new attribute
is an explicit communication to older tools that somethng they
might not support and understand is going on.
