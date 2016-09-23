From: Jaedon Shin <jaedon.shin@gmail.com>
Subject: Re: [PATCH] net: bcmgenet: Fix EPHY reset in power up
Date: Sat, 24 Sep 2016 00:04:22 +0900
Message-ID: <5A71930B-ED19-4690-942D-779F1454C77A@gmail.com>
References: <20160923132004.5734-1-jaedon.shin@gmail.com>
 <20160923140609.GA22965@lunn.ch>
Mime-Version: 1.0 (Mac OS X Mail 10.1 \(3243\))
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>,
        Philippe Reynes <tremyfr@gmail.com>, netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:35664 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1034887AbcIWPE0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 23 Sep 2016 11:04:26 -0400
Received: by mail-pf0-f193.google.com with SMTP id 6so5408121pfl.2
        for <netdev@vger.kernel.org>; Fri, 23 Sep 2016 08:04:26 -0700 (PDT)
In-Reply-To: <20160923140609.GA22965@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

On 23 Sep 2016, at 11:06 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> 
> On Fri, Sep 23, 2016 at 10:20:04PM +0900, Jaedon Shin wrote:
>> The bcmgenet_mii_reset() is always not running in power up sequence
>> after 'commit 62469c76007e ("net: ethernet: bcmgenet: use phydev from
>> struct net_device")'. This'll show extremely high latency and duplicate
>> packets while interface down and up repeatedly.
>> 
>> For now, adds again a private phydev for mii reset when runs power up to
>> open interface.
> 
> Hi Jaedon
> 
> How does this fix the issue? It sounds like you are papering over the
> crack, not truly fixing it.
> 
>       Andrew

Yes, It feel like a workaround, but I think it must need v4.8 stable
version. If we find better way that fixes internal PHY to initialize
after re-open interface, this patch will be dropped.

Additionally,
http://www.spinics.net/lists/netdev/msg350506.html

Thanks,
Jaedon
