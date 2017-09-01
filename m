From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Fri, 1 Sep 2017 15:03:11 +0200
Message-ID: <20170901130311.v5nyx6e6gfats5dg@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, jhs@mojatatu.com, xiyou.wangcong@gmail.com,
        jiri@resnulli.us, intel-wired-lan@lists.osuosl.org,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:35681 "EHLO
        mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751778AbdIANDQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 09:03:16 -0400
Received: by mail-wm0-f41.google.com with SMTP id v2so1125747wmf.0
        for <netdev@vger.kernel.org>; Fri, 01 Sep 2017 06:03:16 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170901012625.14838-1-vinicius.gomes@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I happy to see this posted.  At first glance, it seems like a step in
the right direction.

On Thu, Aug 31, 2017 at 06:26:20PM -0700, Vinicius Costa Gomes wrote:
>  * Time-aware shaper (802.1Qbv):
...
>    S 0x01 300
>    S 0x03 500
> 
>    This means that there are two intervals, the first will have the gate
>    for traffic class 0 open for 300 nanoseconds, the second will have
>    both traffic classes open for 500 nanoseconds.

The i210 doesn't support this in HW, or does it?

>  * Frame Preemption (802.1Qbu):
> 
>    To control even further the latency, it may prove useful to signal which
>    traffic classes are marked as preemptable. For that, 'taprio' provides the
>    preemption command so you set each traffic class as preemptable or not:
> 
>    $ tc qdisc (...) \
>         preemption 0 1 1 1

Neither can the i210 preempt frames, or what am I missing?

The timing of this RFC is good, as I am just finishing up an RFC that
implements time-based transmit using the i210.  I'll try and get that
out ASAP.

Thanks,
Richard
