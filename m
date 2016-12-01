From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2016-12-01
Date: Thu, 01 Dec 2016 11:36:15 -0500 (EST)
Message-ID: <20161201.113615.1134217667803741376.davem@davemloft.net>
References: <1480592692-3653-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:38520 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750708AbcLAQgR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Dec 2016 11:36:17 -0500
In-Reply-To: <1480592692-3653-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Thu, 1 Dec 2016 12:44:49 +0100

> 1) Change the error value when someone tries to run 32bit
>    userspace on a 64bit host from -ENOTSUPP to the userspace
>    exported -EOPNOTSUPP. Fix from Yi Zhao.
> 
> 2) On inbound, ESN sequence numbers are already in network
>    byte order. So don't try to convert it again, this fixes
>    integrity verification for ESN. Fixes from Tobias Brunner.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.
