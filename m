From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6_skip_exthdr: use ipv6_authlen for AH hdrlen
Date: Tue, 19 Sep 2017 15:32:08 -0700 (PDT)
Message-ID: <20170919.153208.1575676406897804623.davem@davemloft.net>
References: <20170919125950.11537-1-qasdfgtyuiop@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: qasdfgtyuiop@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48734 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751361AbdISWcJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 18:32:09 -0400
In-Reply-To: <20170919125950.11537-1-qasdfgtyuiop@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiang Gao <qasdfgtyuiop@gmail.com>
Date: Tue, 19 Sep 2017 08:59:50 -0400

> In ipv6_skip_exthdr, the lengh of AH header is computed manually
> as (hp->hdrlen+2)<<2. However, in include/linux/ipv6.h, a macro
> named ipv6_authlen is already defined for exactly the same job. This
> commit replaces the manual computation code with the macro.

All patch submissions must have a proper signoff.

Also, please use a proper subsystem prefix in your Subject
line "[PATCH] ipv6: Use ipv6_authlen for AH hdrlen in ipv6_skip_exthdr()"
would have been much better as "ipv6: " is the appropriate
subsystem prefix to use here.

Thanks.
