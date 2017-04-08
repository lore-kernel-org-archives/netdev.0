From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2] net: dsa: mv88e6xxx: Make SMI c22/c45
 read/write functions static
Date: Sat, 08 Apr 2017 08:32:08 -0700 (PDT)
Message-ID: <20170408.083208.1460341424526433060.davem@davemloft.net>
References: <20170406194217.13927-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, linux-kernel@vger.kernel.org
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41008 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751137AbdDHPcJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 8 Apr 2017 11:32:09 -0400
In-Reply-To: <20170406194217.13927-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Thu,  6 Apr 2017 12:42:16 -0700

> The SMI clause 22 & 45 read/write operations are local to the global2.c file,
> so make them static. This eliminates the following warning:
 ...
> Suggested-by: Andrew Lunn <andrew@lunn.ch>
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied, thanks Florian.
