From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] [for 4.13] net: qcom/emac: disable flow control
 autonegotiation by default
Date: Wed, 02 Aug 2017 16:15:36 -0700 (PDT)
Message-ID: <20170802.161536.699853895820311600.davem@davemloft.net>
References: <290fdd25-7e05-57c8-8f89-52bb3bae1e59@codeaurora.org>
        <20170802.113531.1671960264039506111.davem@davemloft.net>
        <3c31277c-93c4-c0a5-cf0d-7270d07c432c@codeaurora.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: timur@codeaurora.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60518 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751145AbdHBXPi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 2 Aug 2017 19:15:38 -0400
In-Reply-To: <3c31277c-93c4-c0a5-cf0d-7270d07c432c@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Timur Tabi <timur@codeaurora.org>
Date: Wed, 2 Aug 2017 13:39:34 -0500

> On 08/02/2017 01:35 PM, David Miller wrote:
>> Again, any serious installation will have a system watchdog enabled
>> which will break the pause frame bomb.
> 
> Oh well.  I guess I'll have to carry this patch internally.

So you don't want to run a proper watchdog on your systems?
You want them to just hang there and wait for someone to
notice instead?

> What about patch #2?

No real objection.
