From: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Subject: Re: [PATCH] pktgen: add a new sample script for 40G and above link
 testing
Date: Fri, 25 Aug 2017 15:11:38 +0000
Message-ID: <E0D909EE5BB15A4699798539EA149D7F0779396C@ORSMSX103.amr.corp.intel.com>
References: <1503127531-134546-1-git-send-email-robert.hu@intel.com>
 <20170825111921.061713c8@redhat.com>
 <E0D909EE5BB15A4699798539EA149D7F077932D8@ORSMSX103.amr.corp.intel.com>
 <20170825165929.0d840ab2@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Hu, Robert" <robert.hu@intel.com>,
        "robert.hu@linux.intel.com" <robert.hu@linux.intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:29720 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932414AbdHYPLk (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 11:11:40 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/25/17 10:59 AM, Jesper Dangaard Brouer wrote:
> On Fri, 25 Aug 2017 14:24:28 +0000
> "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com> wrote:
> 
>> On 8/25/17 5:19 AM, Jesper Dangaard Brouer wrote:
>>>>
>>>> Tested with Intel XL710 NIC with Cisco 3172 switch.
>>>>
>>>> It would be even slightly better if the irqbalance service is turned
>>>> off outside.
>>>
>>> Yes, if you don't turn-off (kill) irqbalance it will move around the
>>> IRQs behind your back...
>>
>> Or you can use the --banirq option to irqbalance to ignore your device's
>> interrupts as targets for balancing.
> 
> It might be worth mentioning that --banirq=X is specified for each IRQ
> that you want to exclude, and --banirq is simply specified multiple
> times on the command line.
> 
> Is it possible to tell a running irqbalance that I want to excluded an
> extra IRQ? (just before I do my manual adjustment).

It isn't possible today, since we don't have a way to attach a 
foreground/oneshot irqbalance run to a currently-running daemon.  That's 
an interesting feature enhancement...I can add it to our list as a 
feature request so I don't forget about it.  That way I can also get 
Neil's thoughts on this.

-PJ
