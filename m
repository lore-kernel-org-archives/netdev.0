From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] gre: use nla_get_be32() to extract flowinfo
Date: Sat, 24 Sep 2016 20:08:13 -0400 (EDT)
Message-ID: <20160924.200813.526324223597957426.davem@davemloft.net>
References: <1474740064-13580-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42432 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S935087AbcIYAIP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 20:08:15 -0400
In-Reply-To: <1474740064-13580-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Sat, 24 Sep 2016 14:01:04 -0400

> Eliminate a sparse endianness mismatch warning, use nla_get_be32() to
> extract a __be32 value instead of nla_get_u32().
> 
> Signed-off-by: Lance Richardson <lrichard@redhat.com>

Applied.
