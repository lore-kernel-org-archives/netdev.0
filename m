From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: dsa: mt7530: make functions mt7530_phy_write
 static
Date: Tue, 03 Oct 2017 10:20:30 -0700 (PDT)
Message-ID: <20171003.102030.1150001638629183371.davem@davemloft.net>
References: <20171003104633.27151-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47502 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751090AbdJCRUb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 13:20:31 -0400
In-Reply-To: <20171003104633.27151-1-colin.king@canonical.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Colin King <colin.king@canonical.com>
Date: Tue,  3 Oct 2017 11:46:33 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The function mt7530_phy_write is local to the source and does not need to
> be in global scope, so make it static.
> 
> Cleans up sparse warnings:
> symbol 'mt7530_phy_write' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
