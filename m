From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 02 Aug 2017 11:36:29 -0700 (PDT)
Message-ID: <20170802.113629.1593218394678804041.davem@davemloft.net>
References: <1501623460-3575-2-git-send-email-timur@codeaurora.org>
        <20170802.105453.1408822174555343968.davem@davemloft.net>
        <290fdd25-7e05-57c8-8f89-52bb3bae1e59@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55982 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752387AbdHBSg3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 14:36:29 -0400
In-Reply-To: <290fdd25-7e05-57c8-8f89-52bb3bae1e59@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Wed, 2 Aug 2017 13:23:18 -0500

> It's practically impossible to overload the chip such that it can't
> process the incoming packets fast enough.  I don't know of any
> real-world situation where the EMAC needs to transmit pause frames.

Slow cpus or very expensive stack operations can cause this, it's not
a property of the EMAC chip at all.
