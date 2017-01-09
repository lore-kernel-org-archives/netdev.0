From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/4] net: dsa: Make dsa_switch_ops const
Date: Mon, 09 Jan 2017 14:34:17 -0500 (EST)
Message-ID: <20170109.143417.1830765753133219802.davem@davemloft.net>
References: <20170108225208.15431-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48468 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1763537AbdAITeT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 14:34:19 -0500
In-Reply-To: <20170108225208.15431-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun,  8 Jan 2017 14:52:04 -0800

> This patch series allows us to annotate dsa_switch_ops with a const
> qualifier.

I kinda suspect this will have minor conflicts with the ops overwrite
bug fix I applied to 'net' right?

I think I'll wait until I merge net into net-next before I try to
apply this, and that should happend soon'ish.  I'm just waiting for
Linus to take in my pull request.
