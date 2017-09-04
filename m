From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 0/4] net: dsa: Allow switch drivers to
 indicate number of TX queues
Date: Sun, 03 Sep 2017 20:20:09 -0700 (PDT)
Message-ID: <20170903.202009.2104340600797726296.davem@davemloft.net>
References: <20170902180609.23122-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com, jiri@resnulli.us,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34936 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753124AbdIDDUK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 23:20:10 -0400
In-Reply-To: <20170902180609.23122-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sat,  2 Sep 2017 11:06:05 -0700

> This patch series extracts the parts of the patch set that are likely not to be
> controversial and actually bringing multi-queue support to DSA-created network
> devices.
> 
> With these patches, we can now use sch_multiq as documented under
> Documentation/networking/multique.txt and let applications dedice the switch
> port output queue they want to use. Currently only Broadcom tags utilize that
> information.
> 
> Changes in v2:
> - use a proper define for the number of TX queues in bcm_sf2.c (Andrew)

Hello Florian.

For some reason this series didn't make it completely into patchwork, I only
see patch #1 there.

Can you try submitting again?  If it doesn't work this time I'll just apply
it by hand from my inbox.

Thanks.
