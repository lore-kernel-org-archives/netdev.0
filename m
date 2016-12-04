From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv2 net-next 0/4] MV88E6390 batch two
Date: Sat, 03 Dec 2016 23:15:57 -0500 (EST)
Message-ID: <20161203.231557.1579082148373199155.davem@davemloft.net>
References: <1480736119-12195-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42022 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752128AbcLDEP6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 3 Dec 2016 23:15:58 -0500
In-Reply-To: <1480736119-12195-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Sat,  3 Dec 2016 04:35:15 +0100

> This is the second batch of patches adding support for the
> MV88e6390. They are not sufficient to make it work properly.
> 
> The mv88e6390 has a much expanded set of priority maps. Refactor the
> existing code, and implement basic support for the new device.
> 
> Similarly, the monitor control register has been reworked.
> 
> The mv88e6390 has something odd in its EDSA tagging implementation,
> which means it is not possible to use it. So we need to use DSA
> tagging. This is the first device with EDSA support where we need to
> use DSA, and the code does not support this. So two patches refactor
> the existing code. The two different register definitions are
> separated out, and using DSA on an EDSA capable device is added.
 ...

Series applied.
