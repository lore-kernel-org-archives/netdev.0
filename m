From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] be2net: get rid of custom busy poll code
Date: Fri, 03 Feb 2017 16:07:06 -0500 (EST)
Message-ID: <20170203.160706.1485056581935525081.davem@davemloft.net>
References: <1486059360.21871.6.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sathya.perla@broadcom.com,
        ajit.khaparde@broadcom.com, somnath.kotur@broadcom.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52834 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752441AbdBCVHI (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 16:07:08 -0500
In-Reply-To: <1486059360.21871.6.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Thu, 02 Feb 2017 10:16:00 -0800

> From: Eric Dumazet <edumazet@google.com>
> 
> Compared to custom busy_poll, the generic NAPI one is better, since
> it allows to use GRO, and it removes a lot of code and extra locked
> operations in fast path.
> 
> Signed-off-by: Eric Dumazet <edumazet@google.com>

Applied.
