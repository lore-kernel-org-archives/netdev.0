From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V2] cxgb4: fix -ve error check on a signed iq
Date: Sun, 25 Sep 2016 23:40:12 -0400 (EDT)
Message-ID: <20160925.234012.933201102491235169.davem@davemloft.net>
References: <20160925211445.11234-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hariprasad@chelsio.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55118 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932234AbcIZDk0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Sep 2016 23:40:26 -0400
In-Reply-To: <20160925211445.11234-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Sun, 25 Sep 2016 14:14:45 -0700

> From: Colin Ian King <colin.king@canonical.com>
> 
> iq is unsigned, so the error check for iq < 0 has no effect so errors
> can slip past this check.  Fix this by making iq signed and also
> get_filter_steerq return a signed int so a -ve error can be returned.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied, thanks.
