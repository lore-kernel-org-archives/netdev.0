From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v4 0/9] socket sendmsg MSG_ZEROCOPY
Date: Thu, 03 Aug 2017 21:37:55 -0700 (PDT)
Message-ID: <20170803.213755.1756176029575132196.davem@davemloft.net>
References: <20170803202945.70750-1-willemdebruijn.kernel@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-api@vger.kernel.org,
        willemb@google.com
To: willemdebruijn.kernel@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54834 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750899AbdHDEiA (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 4 Aug 2017 00:38:00 -0400
In-Reply-To: <20170803202945.70750-1-willemdebruijn.kernel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Date: Thu,  3 Aug 2017 16:29:36 -0400

> Introduce zerocopy socket send flag MSG_ZEROCOPY. This extends the
> shared page support (SKBTX_SHARED_FRAG) from sendpage to sendmsg.
> Implement the feature for TCP initially, as large writes benefit
> most.

Looks great, series applied, thanks!
