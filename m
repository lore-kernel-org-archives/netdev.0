From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] liquidio: clear the correct memory
Date: Wed, 05 Apr 2017 06:54:18 -0700 (PDT)
Message-ID: <20170405.065418.597015931851791657.davem@davemloft.net>
References: <20170403181827.GA6505@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: derek.chickles@caviumnetworks.com, prasad.kanneganti@cavium.com,
        satananda.burla@caviumnetworks.com,
        felix.manlunas@caviumnetworks.com,
        raghu.vatsavayi@caviumnetworks.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42082 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932562AbdDENyY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 5 Apr 2017 09:54:24 -0400
In-Reply-To: <20170403181827.GA6505@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 3 Apr 2017 21:18:27 +0300

> There is a cut and paste bug here so we accidentally clear the first
> few bytes of "resp" a second time instead clearing "ctx".
> 
> Fixes: 50c0add534d2 ("liquidio: refactor interrupt moderation code")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
