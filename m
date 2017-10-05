From: David Miller <davem@davemloft.net>
Subject: Re: [next-queue PATCH v4 3/4] net/sched: Introduce Credit Based
 Shaper (CBS) qdisc
Date: Thu, 05 Oct 2017 11:29:09 -0700 (PDT)
Message-ID: <20171005.112909.2052593524154643514.davem@davemloft.net>
References: <20171004002831.18371-4-vinicius.gomes@intel.com>
        <20171004063650.GA1895@nanopsycho>
        <CAEYbN3RjUXGMyxo0t88-ASNVEVQdfXkMzBbMtMHAhqWScOO=Cg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, vinicius.gomes@intel.com, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, rodney.cummings@ni.com
To: levipearson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:47974 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751334AbdJES3L (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 14:29:11 -0400
In-Reply-To: <CAEYbN3RjUXGMyxo0t88-ASNVEVQdfXkMzBbMtMHAhqWScOO=Cg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Levi Pearson <levipearson@gmail.com>
Date: Thu, 5 Oct 2017 12:09:32 -0600

> It would be a shame if this were blocked due to a missing software
> implementation.

Quite the contrary, I think a software implementation is a minimum
requirement for inclusion of this feature.

Without a software implementation, there is no clear definition of
what is supposed to happen, and no clear way for people to test those
expectations unless they have the specific hardware.

I completely agree with Jiri.  Hardware offload first is _not_ how
we do things in the Linux networking.
