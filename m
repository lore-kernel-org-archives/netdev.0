From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH -next] net: phy: test the right variable in
 phy_write_mmd()
Date: Mon, 17 Apr 2017 15:11:01 -0400 (EDT)
Message-ID: <20170417.151101.1654282192272824268.davem@davemloft.net>
References: <20170414191041.GA27478@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, rmk+kernel@armlinux.org.uk, f.fainelli@gmail.com,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57076 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755413AbdDQTLD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Apr 2017 15:11:03 -0400
In-Reply-To: <20170414191041.GA27478@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 14 Apr 2017 22:10:41 +0300

> This is a copy and paste buglet.  We meant to test for ->write_mmd but
> we test for ->read_mmd.
> 
> Fixes: 1ee6b9bc6206 ("net: phy: make phy_(read|write)_mmd() generic MMD accessors")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks Dan.
