From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][next] sctp: make array sctp_sched_ops static
Date: Wed, 11 Oct 2017 20:18:41 -0700 (PDT)
Message-ID: <20171011.201841.213739155323701188.davem@davemloft.net>
References: <20171011101757.18825-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42044 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752123AbdJLDSm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 23:18:42 -0400
In-Reply-To: <20171011101757.18825-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Wed, 11 Oct 2017 11:17:57 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The array sctp_sched_ops  is local to the source and
> does not need to be in global scope, so make it static.
> 
> Cleans up sparse warning:
> symbol 'sctp_sched_ops' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
