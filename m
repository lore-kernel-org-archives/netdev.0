From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: accept 64k - 1 packet length in
 ip6_find_1stfragopt()
Date: Tue, 22 Aug 2017 10:23:48 -0700 (PDT)
Message-ID: <20170822.102348.911807554303990268.davem@davemloft.net>
References: <9597319ba96a966ee580bd04f36584b52dfa2c48.1503059705.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sd@queasysnail.net,
        hannes@stressinduktion.org
To: sbrivio@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38196 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751061AbdHVRXv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 22 Aug 2017 13:23:51 -0400
In-Reply-To: <9597319ba96a966ee580bd04f36584b52dfa2c48.1503059705.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefano Brivio <sbrivio@redhat.com>
Date: Fri, 18 Aug 2017 14:40:53 +0200

> A packet length of exactly IPV6_MAXPLEN is allowed, we should
> refuse parsing options only if the size is 64KiB or more.
> 
> While at it, remove one extra variable and one assignment which
> were also introduced by the commit that introduced the size
> check. Checking the sum 'offset + len' and only later adding
> 'len' to 'offset' doesn't provide any advantage over directly
> summing to 'offset' and checking it.
> 
> Fixes: 6399f1fae4ec ("ipv6: avoid overflow of offset in ip6_find_1stfragopt")
> Signed-off-by: Stefano Brivio <sbrivio@redhat.com>

Applied, thanks.
