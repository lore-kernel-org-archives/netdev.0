From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 02 Aug 2017 11:35:31 -0700 (PDT)
Message-ID: <20170802.113531.1671960264039506111.davem@davemloft.net>
References: <1501623460-3575-2-git-send-email-timur@codeaurora.org>
        <20170802.105453.1408822174555343968.davem@davemloft.net>
        <290fdd25-7e05-57c8-8f89-52bb3bae1e59@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55968 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751648AbdHBSfe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 14:35:34 -0400
In-Reply-To: <290fdd25-7e05-57c8-8f89-52bb3bae1e59@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Wed, 2 Aug 2017 13:23:18 -0500

> On 08/02/2017 12:54 PM, David Miller wrote:
>> And if this kind of thing matters to the user, they will have a
>> software or hardware watchdog driver enabled to break out of this
>> situation.
> 
> The problem is that the user is not going to expect that the EMAC can
> disable the nearby switch(es) when the kernel is hung and not rebooted
> quickly enough.  Internally, this bug/feature has caused quite a bit
> of mayhem, so the problem is real.  No cares about enabling flow
> control -- it just happens to be enabled on some systems where the
> switch agrees to it.  So random individuals can't debug the hardware
> because suddenly the EMAC has gone haywire and disabled the local
> network.

Again, any serious installation will have a system watchdog enabled
which will break the pause frame bomb.
