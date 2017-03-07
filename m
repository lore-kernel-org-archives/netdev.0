From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2017-03-06
Date: Tue, 07 Mar 2017 15:02:03 -0800 (PST)
Message-ID: <20170307.150203.1179689043671071948.davem@davemloft.net>
References: <1488783448-12588-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38662 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756158AbdCGXTd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 7 Mar 2017 18:19:33 -0500
In-Reply-To: <1488783448-12588-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 6 Mar 2017 07:57:25 +0100

> 1) Fix lockdep splat on xfrm policy subsystem initialization.
>    From Florian Westphal.
> 
> 2) When using socket policies on IPv4-mapped IPv6 addresses,
>    we access the flow informations of the wrong address family
>    what leads to an out of bounds access. Fix this by using
>    the family we get with the dst_entry, like we do it for the
>    standard policy lookup.
> 
> 3) vti6 can report a PMTU below IPV6_MIN_MTU. Fix this by
>    adding a check for that before sending a ICMPV6_PKT_TOOBIG
>    message.
> 
> Please pull or let me know if there are problems.

Pulled, thanks!
