From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: Use ipv6_authlen for len in ipv6_skip_exthdr
Date: Wed, 20 Sep 2017 13:45:38 -0700 (PDT)
Message-ID: <20170920.134538.445868998868419835.davem@davemloft.net>
References: <20170920161817.16203-1-qasdfgtyuiop@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: trivial@kernel.org, netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru,
        yoshfuji@linux-ipv6.org
To: qasdfgtyuiop@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37008 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdITUpl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 16:45:41 -0400
In-Reply-To: <20170920161817.16203-1-qasdfgtyuiop@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xiang Gao <qasdfgtyuiop@gmail.com>
Date: Wed, 20 Sep 2017 12:18:17 -0400

> In ipv6_skip_exthdr, the lengh of AH header is computed manually
> as (hp->hdrlen+2)<<2. However, in include/linux/ipv6.h, a macro
> named ipv6_authlen is already defined for exactly the same job. This
> commit replaces the manual computation code with the macro.
> 
> Signed-off-by: Xiang Gao <qasdfgtyuiop@gmail.com>

Applied, thank you.
