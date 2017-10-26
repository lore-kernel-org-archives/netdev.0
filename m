From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] tun: allow positive return values on
 dev_get_valid_name() call
Date: Thu, 26 Oct 2017 10:11:53 +0900 (KST)
Message-ID: <20171026.101153.1046964931932247346.davem@davemloft.net>
References: <20171025185050.22102-1-julien@arista.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xiyou.wangcong@gmail.com
To: julien@arista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55980 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751911AbdJZBL4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 21:11:56 -0400
In-Reply-To: <20171025185050.22102-1-julien@arista.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Gomes <julien@arista.com>
Date: Wed, 25 Oct 2017 11:50:50 -0700

> If the name argument of dev_get_valid_name() contains "%d", it will try
> to assign it a unit number in __dev__alloc_name() and return either the
> unit number (>= 0) or an error code (< 0).
> Considering positive values as error values prevent tun device creations
> relying this mechanism, therefor we should only consider negative values
> as errors here.
> 
> Signed-off-by: Julien Gomes <julien@arista.com>

Applied.
