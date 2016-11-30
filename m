From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net V2] net/sched: pedit: make sure that offset is valid
Date: Tue, 29 Nov 2016 19:46:52 -0500 (EST)
Message-ID: <20161129.194652.16671380953423752.davem@davemloft.net>
References: <20161128105640.32363-1-amir@vadai.me>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com, jhs@mojatatu.com,
        ogerlitz@mellanox.com, hadarh@mellanox.com, jiri@mellanox.com
To: amir@vadai.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38118 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752694AbcK3Aqy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 19:46:54 -0500
In-Reply-To: <20161128105640.32363-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Amir Vadai <amir@vadai.me>
Date: Mon, 28 Nov 2016 12:56:40 +0200

> Add a validation function to make sure offset is valid:
> 1. Not below skb head (could happen when offset is negative).
> 2. Validate both 'offset' and 'at'.
> 
> Signed-off-by: Amir Vadai <amir@vadai.me>

Applied and queued up for -stable, thanks.
