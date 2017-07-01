From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] sctp: remove an unnecessary check from
 sctp_endpoint_destroy
Date: Sat, 01 Jul 2017 08:47:19 -0700 (PDT)
Message-ID: <20170701.084719.435039770131658866.davem@davemloft.net>
References: <9a583ea8d84ee913f4c7ba1571e6cfeb24c9ef8b.1498728486.git.lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
        marcelo.leitner@gmail.com, nhorman@tuxdriver.com
To: lucien.xin@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59188 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751822AbdGAPr3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Jul 2017 11:47:29 -0400
In-Reply-To: <9a583ea8d84ee913f4c7ba1571e6cfeb24c9ef8b.1498728486.git.lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Xin Long <lucien.xin@gmail.com>
Date: Thu, 29 Jun 2017 17:28:06 +0800

> ep->base.sk gets it's value since sctp_endpoint_new, nowhere
> will change it. So there's no need to check if it's null, as
> it can never be null.
> 
> Signed-off-by: Xin Long <lucien.xin@gmail.com>

Applied, thanks.
