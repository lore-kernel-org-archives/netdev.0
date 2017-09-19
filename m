From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: ipv6: fix regression of no RTM_DELADDR sent after
 DAD failure
Date: Tue, 19 Sep 2017 16:43:28 -0700 (PDT)
Message-ID: <20170919.164328.373486119289403420.davem@davemloft.net>
References: <1504536775-23533-1-git-send-email-mmanning@brocade.com>
        <20170907.191843.836588795188250550.davem@davemloft.net>
        <ce045f3d-c99a-e9a2-a0e7-c4d0410f0665@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com
To: mmanning@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51494 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751309AbdISXn3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:43:29 -0400
In-Reply-To: <ce045f3d-c99a-e9a2-a0e7-c4d0410f0665@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mike Manning <mmanning@brocade.com>
Date: Mon, 18 Sep 2017 14:06:40 +0100

> In the absence of a reply from Mahesh, I would be most grateful for
> anyone familiar with the IPv6 code to review this 1-line fix.
> 
> Or if not, then I request that the commit f784ad3d79e5 is backed out,
> as its intention is to remove the redundant but harmless RTM_DELADDR
> for addresses in tentative state, but is also incorrectly removing the
> very necessary RTM_DELADDR when an address is deleted that was previously
> notified with an RTM_NEWADDR as being in tentative dadfailed state.

I've applied your patch, and queued it up for -stable, thanks.
