From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ip6_gre: fix flowi6_proto value in
 ip6gre_xmit_other()
Date: Sat, 24 Sep 2016 09:45:18 -0400 (EDT)
Message-ID: <20160924.094518.409506203757167037.davem@davemloft.net>
References: <1474660229-5665-1-git-send-email-lrichard@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shmulik.ladkani@gmail.com, jbenc@redhat.com
To: lrichard@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37508 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751900AbcIXNpV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 09:45:21 -0400
In-Reply-To: <1474660229-5665-1-git-send-email-lrichard@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lance Richardson <lrichard@redhat.com>
Date: Fri, 23 Sep 2016 15:50:29 -0400

> Similar to commit 3be07244b733 ("ip6_gre: fix flowi6_proto value in
> xmit path"), set flowi6_proto to IPPROTO_GRE for output route lookup.
> 
> Up until now, ip6gre_xmit_other() has set flowi6_proto to a bogus value.
> This affected output route lookup for packets sent on an ip6gretap device
> in cases where routing was dependent on the value of flowi6_proto.
> 
> Since the correct proto is already set in the tunnel flowi6 template via
> commit 252f3f5a1189 ("ip6_gre: Set flowi6_proto as IPPROTO_GRE in xmit
> path."), simply delete the line setting the incorrect flowi6_proto value.
> 
> Suggested-by: Jiri Benc <jbenc@redhat.com>
> Fixes: commit c12b395a4664 ("gre: Support GRE over IPv6")
> Reviewed-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
> Signed-off-by: Lance Richardson <lrichard@redhat.com>
> ---
> v2: expanded commit description as suggested by Shmulik Ladkani.

Applied and queued up for -stable with Fixes tag fixes up.

Thanks.
