From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: core: add missing check for uid_range in
 rule_exists.
Date: Wed, 09 Nov 2016 13:28:27 -0500 (EST)
Message-ID: <20161109.132827.579982211587371286.davem@davemloft.net>
References: <1478445385-94937-1-git-send-email-lorenzo@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ek@google.com, eric.dumazet@gmail.com,
        zenczykowski@gmail.com
To: lorenzo@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38524 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751847AbcKIS22 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Nov 2016 13:28:28 -0500
In-Reply-To: <1478445385-94937-1-git-send-email-lorenzo@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lorenzo Colitti <lorenzo@google.com>
Date: Mon,  7 Nov 2016 00:16:25 +0900

> Without this check, it is not possible to create two rules that
> are identical except for their UID ranges. For example:
> 
> root@net-test:/# ip rule add prio 1000 lookup 300
> root@net-test:/# ip rule add prio 1000 uidrange 100-200 lookup 300
> RTNETLINK answers: File exists
> root@net-test:/# ip rule add prio 1000 uidrange 100-199 lookup 100
> root@net-test:/# ip rule add prio 1000 uidrange 200-299 lookup 200
> root@net-test:/# ip rule add prio 1000 uidrange 300-399 lookup 100
> RTNETLINK answers: File exists
> 
> Tested: https://android-review.googlesource.com/#/c/299980/
> Signed-off-by: Lorenzo Colitti <lorenzo@google.com>

Applied.
