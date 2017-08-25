From: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] pktgen: add a new sample script for 40G and above link
 testing
Date: Fri, 25 Aug 2017 14:24:28 +0000
Message-ID: <E0D909EE5BB15A4699798539EA149D7F077932D8@ORSMSX103.amr.corp.intel.com>
References: <1503127531-134546-1-git-send-email-robert.hu@intel.com>
 <20170825111921.061713c8@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "robert.hu@linux.intel.com" <robert.hu@linux.intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        "Hu, Robert" <robert.hu@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga04.intel.com ([192.55.52.120]:64624 "EHLO mga04.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933274AbdHYOYa (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 10:24:30 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/17 5:19 AM, Jesper Dangaard Brouer wrote:
>>
>> Tested with Intel XL710 NIC with Cisco 3172 switch.
>>
>> It would be even slightly better if the irqbalance service is turned
>> off outside.
> 
> Yes, if you don't turn-off (kill) irqbalance it will move around the
> IRQs behind your back...

Or you can use the --banirq option to irqbalance to ignore your device's 
interrupts as targets for balancing.

Cheers,
-PJ
