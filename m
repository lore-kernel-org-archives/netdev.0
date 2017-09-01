From: Robert Hoo <robert.hu@linux.intel.com>
Subject: Re: [PATCH] pktgen: add a new sample script for 40G and above link
 testing
Date: Fri, 01 Sep 2017 21:57:25 +0800
Message-ID: <1504274245.50064.27.camel@linux.intel.com>
References: <1503127531-134546-1-git-send-email-robert.hu@intel.com>
         <20170825111921.061713c8@redhat.com>
         <E0D909EE5BB15A4699798539EA149D7F077932D8@ORSMSX103.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <brouer@redhat.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([134.134.136.65]:8036 "EHLO mga03.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751966AbdIAN51 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 1 Sep 2017 09:57:27 -0400
In-Reply-To: <E0D909EE5BB15A4699798539EA149D7F077932D8@ORSMSX103.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2017-08-25 at 14:24 +0000, Waskiewicz Jr, Peter wrote:
> On 8/25/17 5:19 AM, Jesper Dangaard Brouer wrote:
> >>
> >> Tested with Intel XL710 NIC with Cisco 3172 switch.
> >>
> >> It would be even slightly better if the irqbalance service is turned
> >> off outside.
> > 
> > Yes, if you don't turn-off (kill) irqbalance it will move around the
> > IRQs behind your back...
> 
> Or you can use the --banirq option to irqbalance to ignore your device's 
> interrupts as targets for balancing.

Oh, I wasn't aware of this parameter. I will be glad to have try later.
Meanwhile, in my test above, the irqbalance service just affect result
very little.
> 
> Cheers,
> -PJ
