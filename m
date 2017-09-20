From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Wed, 20 Sep 2017 07:56:16 +0200
Message-ID: <20170920055616.snd6tndvbdnesnck@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170920015911.18999-1-levipearson@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: vinicius.gomes@intel.com, netdev@vger.kernel.org,
        intel-wired-lan@lists.osuosl.org, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, henrik@austad.us
To: levipearson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f176.google.com ([209.85.128.176]:57059 "EHLO
        mail-wr0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751428AbdITF4W (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 01:56:22 -0400
Received: by mail-wr0-f176.google.com with SMTP id r74so1172174wrb.13
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 22:56:21 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170920015911.18999-1-levipearson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 07:59:11PM -0600, levipearson@gmail.com wrote:
> If some endpoint device shows up with direct Qbv support, this interface would
> probably work well there too, although a talker would need to be able to
> schedule its transmits pretty precisely to achieve the lowest possible latency.

This is an argument for SO_TXTIME.

> One concern here is calling the base-time parameter an interval; it's really
> an absolute time with respect to the PTP timescale. Good documentation will
> be important to this one, since the specification discusses some subtleties
> regarding the impact of different time values chosen here.
> 
> The format for specifying the actual intervals such as cycle-time could prove
> to be an important detail as well; Qbv specifies cycle-time as a ratio of two
> integers expressed in seconds, while extension-time is specified as an integer
> number of nanoseconds.
> 
> Precision with the cycle-time is especially important, since base-time can be
> almost arbitrarily far in the past or future, and any given cycle start should
> be calculable from the base-time plus/minus some integer multiple of cycle-
> time.

The above three points also.

Thanks,
Richard
