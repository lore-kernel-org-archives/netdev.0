From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] mcs7780: Silence uninitialized variable warning
Date: Sat, 29 Jul 2017 23:28:55 -0700 (PDT)
Message-ID: <20170729.232855.1831311386560187695.davem@davemloft.net>
References: <20170728144511.tf7nc672hwo35rnn@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: samuel@sortiz.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47718 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750951AbdG3G24 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 02:28:56 -0400
In-Reply-To: <20170728144511.tf7nc672hwo35rnn@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 28 Jul 2017 17:45:11 +0300

> -	__u16 rval;
> +	__u16 rval = -1;

Fixing a bogus warning by assigning a signed constant to an
unsigned variable doesn't really make me all that happy.

I don't think I'll apply this, sorry.
