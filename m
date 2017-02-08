From: David Miller <davem@davemloft.net>
Subject: Re: [patch net-next] net: dsa: bcm_sf2: cleanup
 bcm_sf2_cfp_rule_get() a little
Date: Wed, 08 Feb 2017 13:27:24 -0500 (EST)
Message-ID: <20170208.132724.942207581380658378.davem@davemloft.net>
References: <20170207131527.GB31552@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, f.fainelli@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56022 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750970AbdBHS2P (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 13:28:15 -0500
In-Reply-To: <20170207131527.GB31552@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Tue, 7 Feb 2017 16:15:27 +0300

> This patch doesn't affect how the code works.
> 
> My static checker complains that the mask and shift doesn't make sense
> because 0xffffff << 16 goes beyond the end of 32 bits.  It should be
> 0xffff instead but the existing code won't cause runtime bugs.
> 
> Also the casting here is not needed and not consistent with the rest of
> the code.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
