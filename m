From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: fec: Issue error for missing but
 expected PHY
Date: Sun, 30 Jul 2017 19:26:17 -0700 (PDT)
Message-ID: <20170730.192617.1177576067292281322.davem@davemloft.net>
References: <1501445466-23518-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fugang.duan@nxp.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59250 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751574AbdGaC0S (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Jul 2017 22:26:18 -0400
In-Reply-To: <1501445466-23518-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sun, 30 Jul 2017 22:11:06 +0200

> If the PHY is missing but expected, e.g. because of a typ0 in the dt
> file, it is not possible to open the interface. ip link returns:
> 
> RTNETLINK answers: No such device
> 
> It is not very obvious what the problem is. Add a netdev_err() in this
> case to make it easier to debug the issue.
> 
> [   21.409385] fec 2188000.ethernet eth0: Unable to connect to phy
> RTNETLINK answers: No such device
> 
> Signed-off-by: Andrew Lunn <andrew@lunn.ch>

Applied.
