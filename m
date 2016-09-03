From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 0/4] net: smsc911x: Move phy and interrupt config
Date: Fri, 02 Sep 2016 17:28:48 -0700 (PDT)
Message-ID: <20160902.172848.1669713742736541644.davem@davemloft.net>
References: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steve.glendinning@shawell.net,
        sergei.shtylyov@cogentembedded.com, andrew@lunn.ch,
        will.deacon@arm.com
To: jeremy.linton@arm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59488 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751540AbcICA2y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 20:28:54 -0400
In-Reply-To: <1472760909-19688-1-git-send-email-jeremy.linton@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Linton <jeremy.linton@arm.com>
Date: Thu,  1 Sep 2016 15:15:05 -0500

> v2-v3: Move error handing into separate patch, replace a couple cases
>  of fixed errors with the errors being returned from the failing functions.
>  Hoist irq handler.
> 
> The smsc911x driver is doing a number of things in its probe routine that
> should be delayed until the interface is started. Because of this, the module
> cannot be unloaded, the phy states are incorrect/stale if the interface isn't
> running, open's unnecessarily fail causing network configuration problems, and
> the /proc/irq nodes are incorrectly named.
> 
> Clean up a number of these problems by moving the mdio and interrupt
> configuration into the smsc911x_open routine.

Series applied, thanks.
