From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Thu, 7 Sep 2017 17:53:15 +0200
Message-ID: <20170907155315.5gqy5e4susl25wa2@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170907053411.GA6580@sisyphus.home.austad.us>
 <20170907124018.deinzo3c4ice3q7n@localhost>
 <20170907152751.GA9064@sisyphus.home.austad.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Vinicius Costa Gomes <vinicius.gomes@intel.com>,
        netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Henrik Austad <henrik@austad.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f181.google.com ([209.85.128.181]:35774 "EHLO
        mail-wr0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752200AbdIGPxV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 7 Sep 2017 11:53:21 -0400
Received: by mail-wr0-f181.google.com with SMTP id m18so261274wrm.2
        for <netdev@vger.kernel.org>; Thu, 07 Sep 2017 08:53:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170907152751.GA9064@sisyphus.home.austad.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 07, 2017 at 05:27:51PM +0200, Henrik Austad wrote:
> On Thu, Sep 07, 2017 at 02:40:18PM +0200, Richard Cochran wrote:
> And if you want to this driver to act as a bridge, how do you accomodate 
> change in network requirements? (i.e. how does this work with switchdev?)

To my understanding, this Qdisc idea provides QoS for the host's
transmitted traffic, and nothing more.

> - Or am I overthinking this?

Being able to configure the external ports of a switchdev is probably
a nice feature, but that is another story.  (But maybe I misunderstood
the authors' intent!)

> If you have more than 1 application in userspace that wants to send data 
> using this scheduler, how do you ensure fair transmission of frames? (both 
> how much bandwidth they use,

There are many ways to handle this, and we shouldn't put any of that
policy into the kernel.  For example, there might be a monolithic
application with configurable threads, or an allocation server that
grants bandwidth to applications via IPC, or a multiplexing stream
server like jack, pulse, etc, and so on...

> but also ordering of frames from each application)

Not sure what you mean by this.

> Do you expect all of this to be handled in userspace?

Yes, I do.

Thanks,
Richard
