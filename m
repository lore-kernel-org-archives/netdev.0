From: David Miller <davem@davemloft.net>
Subject: Re: [Patch RFC net-next] net: usb: r8152: Fix rx_bytes/tx_bytes to
 include FCS
Date: Thu, 18 May 2017 11:22:56 -0400 (EDT)
Message-ID: <20170518.112256.671702749693595449.davem@davemloft.net>
References: <1495052615-14360-1-git-send-email-andrew@lunn.ch>
        <286d107e-2380-f8e9-3edf-c949707ea235@gmail.com>
        <20170518150925.GB707@lunn.ch>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        hayeswang@realtek.com, mario_limonciello@dell.com
To: andrew@lunn.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44328 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933246AbdERPW6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 18 May 2017 11:22:58 -0400
In-Reply-To: <20170518150925.GB707@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andrew Lunn <andrew@lunn.ch>
Date: Thu, 18 May 2017 17:09:25 +0200

> Since these are software counters, they can be consistent. From a
> practical point of view, i doubt they ever will all be consistent,
> there are simply too many drivers to test and change if
> needed. However, for the ones somebody cares about, they can be made
> consistent.
> 
> I care about r8152, and would like to make it consistent with asix,
> dsa, e1000e.

No objection from me for making software counters consistent.
