From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [RFC net-next 0/5] TSN: Add qdisc-based config interfaces for
 traffic shapers
Date: Tue, 12 Sep 2017 06:56:44 +0200
Message-ID: <20170912045644.aqujy7pyc2ugsaa4@localhost>
References: <20170901012625.14838-1-vinicius.gomes@intel.com>
 <20170907053411.GA6580@sisyphus.home.austad.us>
 <87k21am10j.fsf@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Henrik Austad <henrik@austad.us>, netdev@vger.kernel.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        intel-wired-lan@lists.osuosl.org, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com
To: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:46043 "EHLO
        mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751045AbdILE4u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 12 Sep 2017 00:56:50 -0400
Received: by mail-wm0-f44.google.com with SMTP id f199so52732721wme.0
        for <netdev@vger.kernel.org>; Mon, 11 Sep 2017 21:56:49 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <87k21am10j.fsf@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 07, 2017 at 06:29:00PM -0700, Vinicius Costa Gomes wrote:
> >>  * Time-aware shaper (802.1Qbv):
> >>
> >>    The idea we are currently exploring is to add a "time-aware", priority based
> >>    qdisc, that also exposes the Tx queues available and provides a mechanism for
> >>    mapping priority <-> traffic class <-> Tx queues in a similar fashion as
> >>    mqprio. We are calling this qdisc 'taprio', and its 'tc' cmd line would be:
> >
> > As far as I know, this is not supported by i210, and if time-aware shaping
> > is enabled in the network - you'll be queued on a bridge until the window
> > opens as time-aware shaping is enforced on the tx-port and not on rx. Is
> > this required in this driver?
> 
> Yeah, i210 doesn't support the time-aware shaper. I think the second
> part of your question doesn't really apply, then.

Actually, you can implement 802.1Qbv (as an end station) quite easily
using the i210.  I'll show how by posting a series after net-next
opens up again.

Thanks,
Richard
