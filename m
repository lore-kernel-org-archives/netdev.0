From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] mlxsw: spectrum: remove redundant check if err is zero
Date: Sat, 24 Sep 2016 08:28:42 -0400 (EDT)
Message-ID: <20160924.082842.382648996095761130.davem@davemloft.net>
References: <20160923110245.18977-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@mellanox.com, idosch@mellanox.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752656AbcIXM2r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 24 Sep 2016 08:28:47 -0400
In-Reply-To: <20160923110245.18977-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Fri, 23 Sep 2016 12:02:45 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> There is an earlier check and return if err is non-zero, so
> the check to see if it is zero is redundant in every iteration
> of the loop and hence the check can be removed.
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to net-next.
