From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: mv88e6xxx: Fix ingress rate removal for mv6131
 chips
Date: Tue, 23 Aug 2016 16:58:03 -0700 (PDT)
Message-ID: <20160823.165803.453816849474862093.davem@davemloft.net>
References: <1471902428-24250-1-git-send-email-jm@lentin.co.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        netdev@vger.kernel.org
To: jm@lentin.co.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55902 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932488AbcHWX6O (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 23 Aug 2016 19:58:14 -0400
In-Reply-To: <1471902428-24250-1-git-send-email-jm@lentin.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jamie Lentin <jm@lentin.co.uk>
Date: Mon, 22 Aug 2016 22:47:08 +0100

> The PORT_RATE_CONTROL register works differently on 88e6095/6095f/6131
> in comparison to 6123/61/65, and 0x0 disables. The distinction was lost
> Linux 4.1 --> 4.2
> 
> Signed-off-by: Jamie Lentin <jm@lentin.co.uk>

Applied.
