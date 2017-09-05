From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v2 RESEND 0/4] net: dsa: Allow switch drivers
 to indicate number of TX queues
Date: Tue, 05 Sep 2017 11:53:50 -0700 (PDT)
Message-ID: <20170905.115350.1831561116655584584.davem@davemloft.net>
References: <20170904032703.4593-1-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andrew@lunn.ch,
        vivien.didelot@savoirfairelinux.com
To: f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36928 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752011AbdIESxv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 5 Sep 2017 14:53:51 -0400
In-Reply-To: <20170904032703.4593-1-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Fainelli <f.fainelli@gmail.com>
Date: Sun,  3 Sep 2017 20:26:59 -0700

> This patch series extracts the parts of the patch set that are likely not to be
> controversial and actually bringing multi-queue support to DSA-created network
> devices.
> 
> With these patches, we can now use sch_multiq as documented under
> Documentation/networking/multique.txt and let applications dedice the switch
> port output queue they want to use. Currently only Broadcom tags utilize that
> information.
> 
> Resending based on David's feedback regarding the patches not in patchwork.
> 
> Changes in v2:
> - use a proper define for the number of TX queues in bcm_sf2.c (Andrew)
> 
> Changes from RFC:
> 
> - dropped the ability to configure RX queues since we don't do anything with
>   those just yet
> - dropped the patches that dealt with binding the DSA slave network devices
>   queues with their master network devices queues this will be worked on
>   separately.

Series applied, thanks.
