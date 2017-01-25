From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/2] Work around missing PHY prodcut ID in
 mv88e6390
Date: Wed, 25 Jan 2017 13:25:09 -0500 (EST)
Message-ID: <20170125.132509.1614793375095964218.davem@davemloft.net>
References: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
        gregory.clement@free-electrons.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57528 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751513AbdAYSZ0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Jan 2017 13:25:26 -0500
In-Reply-To: <1485309314-23942-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Wed, 25 Jan 2017 02:55:12 +0100

> The internal PHYs of the MV88E6390 have a Marvell OUI, but the product
> ID is zero. Work around this by trapping reads to the ID, and if it is
> zero, return the MV88E6390 family ID.

Because of the ID masking issue, I am expecting a respin of this.
