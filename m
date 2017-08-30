From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: dsa: bcm_sf2: Fix number of CFP entries for
 BCM7278
Date: Wed, 30 Aug 2017 16:04:22 -0700 (PDT)
Message-ID: <20170830.160422.93209720688760528.davem@davemloft.net>
References: <1504121973-8438-1-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36346 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751237AbdH3XEX (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Aug 2017 19:04:23 -0400
In-Reply-To: <1504121973-8438-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 30 Aug 2017 12:39:33 -0700

> BCM7278 has only 128 entries while BCM7445 has the full 256 entries set,
> fix that.
> 
> Fixes: 7318166cacad ("net: dsa: bcm_sf2: Add support for ethtool::rxnfc")
> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>

Applied and queued up for -stable, thanks.

I hope we remember to increase CFP_NUM_RULES if we ever get a chip
that supports more than 256... :-/
