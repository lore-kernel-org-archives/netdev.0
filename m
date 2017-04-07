From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] net: dsa: Receive path simplifications
Date: Fri, 07 Apr 2017 14:17:33 -0700 (PDT)
Message-ID: <20170407.141733.438296944601778974.davem@davemloft.net>
References: <20170407204154.9651-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:35506 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756319AbdDGVRg (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Apr 2017 17:17:36 -0400
In-Reply-To: <20170407204154.9651-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Fri,  7 Apr 2017 13:41:51 -0700

> This patch series does factor the common code found in all tag implementations
> into dsa_switch_rcv(). The original motivation was to add GRO support, but this
> may be a lot of work with unclear benefits at this point.

Let's get the other new DSA driver merged and then you can respin this and
make sure all the new tag drivers get handled properly.
