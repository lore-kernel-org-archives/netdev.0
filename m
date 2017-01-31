From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: dsa: bcm_sf2: Fix build module
Date: Tue, 31 Jan 2017 13:37:25 -0500 (EST)
Message-ID: <20170131.133725.1452309965989023156.davem@davemloft.net>
References: <20170131031716.31304-1-f.fainelli@gmail.com>
        <20170131.003200.1606954363885799024.davem@davemloft.net>
        <8cdf8334-7b1e-641b-44b8-aec6a37d1b8c@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:41462 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751195AbdAaShc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2017 13:37:32 -0500
In-Reply-To: <8cdf8334-7b1e-641b-44b8-aec6a37d1b8c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Tue, 31 Jan 2017 10:32:38 -0800

> On 01/30/2017 09:32 PM, David Miller wrote:
>> From: Florian Fainelli <f.fainelli@gmail.com>
>> Date: Mon, 30 Jan 2017 19:17:16 -0800
>> 
>>> Commit 7318166cacad ("net: dsa: bcm_sf2: Add support for
>>> ethtool::rxnfc") added a new object to build: bcm_sf2_cfp.o, but in
>>> doing so, we essentially just built this object and no longer bcm_sf2.o.
>>>
>>> Fix this by creating a module named bcm-sf2.ko which links in bcm_sf2.o
>>> and bcm_sf2_cfp.o.
>>>
>>> Fixes: 7318166cacad ("net: dsa: bcm_sf2: Add support for ethtool::rxnfc")
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> 
>> Applied, thanks.
> 
> I don't see it showing up on next-next yet, is it just queued locally?
> Thanks!

The perils of working on different machines during the day :-)

It should be there now, sorry about that.
