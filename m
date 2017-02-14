From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: qcom/emac: fix a sizeof() typo
Date: Mon, 13 Feb 2017 22:21:22 -0500 (EST)
Message-ID: <20170213.222122.338973843065896613.davem@davemloft.net>
References: <20170213110021.GA17205@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: timur@codeaurora.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55414 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751370AbdBNDVZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 22:21:25 -0500
In-Reply-To: <20170213110021.GA17205@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Mon, 13 Feb 2017 14:00:22 +0300

> We had intended to say "sizeof(u32)" but the "u" is missing.
> Fortunately, sizeof(32) is also 4, so the original code still works.
> 
> Fixes: c4e7beea2192 ("net: qcom/emac: add ethtool support for reading hardware registers")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied.
