From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: mv88e6xxx: fix error code in
 mv88e6390_serdes_power()
Date: Sun, 25 Jun 2017 11:40:46 -0400 (EDT)
Message-ID: <20170625.114046.640050293672272051.davem@davemloft.net>
References: <20170623151703.stzh2ur3wizbylbi@mwanda>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: dan.carpenter@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40292 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751020AbdFYPks (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 25 Jun 2017 11:40:48 -0400
In-Reply-To: <20170623151703.stzh2ur3wizbylbi@mwanda>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <dan.carpenter@oracle.com>
Date: Fri, 23 Jun 2017 18:17:04 +0300

> We're accidentally returning the wrong variable.  "cmode" is
> uninitialized at this point so it causes a static checker warning.
> 
> Fixes: 6335e9f2446b ("net: dsa: mv88e6xxx: mv88e6390X SERDES support")
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

Applied, thanks.
