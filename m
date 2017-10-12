From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/5] Enable ACB for bcm_sf2 and bcmsysport
Date: Thu, 12 Oct 2017 12:19:43 -0700 (PDT)
Message-ID: <20171012.121943.242637521819341132.davem@davemloft.net>
References: <20171011175752.22030-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55382 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752308AbdJLTTp (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 12 Oct 2017 15:19:45 -0400
In-Reply-To: <20171011175752.22030-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Wed, 11 Oct 2017 10:57:47 -0700

> This patch series enables Broadcom's Advanced Congestion Buffering mechanism
> which requires cooperation between the CPU/Management Ethernet MAC controller
> and the switch.
> 
> I took the notifier approach because ultimately the information we need to
> carry to the master network device is DSA specific and I saw little room for
> generalizing beyond what DSA requires. Chances are that this is highly specific
> to the Broadcom HW as I don't know of any HW out there that supports something
> nearly similar for similar or identical needs.

Series applied, thanks.
