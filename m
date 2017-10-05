From: David Miller <davem@davemloft.net>
Subject: Re: [next-queue PATCH v4 3/4] net/sched: Introduce Credit Based
 Shaper (CBS) qdisc
Date: Thu, 05 Oct 2017 12:05:08 -0700 (PDT)
Message-ID: <20171005.120508.2267452751875787466.davem@davemloft.net>
References: <CAEYbN3RjUXGMyxo0t88-ASNVEVQdfXkMzBbMtMHAhqWScOO=Cg@mail.gmail.com>
        <20171005.112909.2052593524154643514.davem@davemloft.net>
        <CY1PR0401MB1536A44D0AB459BB9618664A92700@CY1PR0401MB1536.namprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: levipearson@gmail.com, jiri@resnulli.us, vinicius.gomes@intel.com,
        netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us
To: rodney.cummings@ni.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:48690 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdJETFL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 15:05:11 -0400
In-Reply-To: <CY1PR0401MB1536A44D0AB459BB9618664A92700@CY1PR0401MB1536.namprd04.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Rodney Cummings <rodney.cummings@ni.com>
Date: Thu, 5 Oct 2017 18:41:48 +0000

> The IEEE Std 802.1Q specs for credit-based shaper require precise transmit decisions
> within a 125 microsecond window of time.
> 
> Even with the Preempt RT patch or similar enhancements, that isn't very practical
> as software-only. I doubt that software would conform to the standard's
> requirements.
> 
> This is analogous to memory, or CPU.

I feel like this is looking for an excuse to not have to at least try to implement
the software version of CBS.
