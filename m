From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH] pktgen: add a new sample script for 40G and above link
 testing
Date: Fri, 25 Aug 2017 16:59:29 +0200
Message-ID: <20170825165929.0d840ab2@redhat.com>
References: <1503127531-134546-1-git-send-email-robert.hu@intel.com>
        <20170825111921.061713c8@redhat.com>
        <E0D909EE5BB15A4699798539EA149D7F077932D8@ORSMSX103.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Hu, Robert" <robert.hu@intel.com>,
        "robert.hu@linux.intel.com" <robert.hu@linux.intel.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        brouer@redhat.com
To: "Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35440 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932326AbdHYO7g (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 25 Aug 2017 10:59:36 -0400
In-Reply-To: <E0D909EE5BB15A4699798539EA149D7F077932D8@ORSMSX103.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 25 Aug 2017 14:24:28 +0000
"Waskiewicz Jr, Peter" <peter.waskiewicz.jr@intel.com> wrote:

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

It might be worth mentioning that --banirq=X is specified for each IRQ
that you want to exclude, and --banirq is simply specified multiple
times on the command line.

Is it possible to tell a running irqbalance that I want to excluded an
extra IRQ? (just before I do my manual adjustment).

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Principal Kernel Engineer at Red Hat
  LinkedIn: http://www.linkedin.com/in/brouer
