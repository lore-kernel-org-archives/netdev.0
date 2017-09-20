From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: TSN Scorecard, was Re: [RFC net-next 0/5] TSN: Add qdisc-based
 config interfaces for traffic shapers
Date: Wed, 20 Sep 2017 07:49:19 +0200
Message-ID: <20170920054919.jtqckuybsu42tvpk@localhost>
References: <20170918081248.txhars53icbqsvld@localhost>
 <20170920051754.21745-1-levipearson@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        vinicius.gomes@intel.com, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, henrik@austad.us
To: levipearson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:44033 "EHLO
        mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751175AbdITFtZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 01:49:25 -0400
Received: by mail-wm0-f48.google.com with SMTP id 189so3004096wmh.1
        for <netdev@vger.kernel.org>; Tue, 19 Sep 2017 22:49:25 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20170920051754.21745-1-levipearson@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 19, 2017 at 11:17:54PM -0600, levipearson@gmail.com wrote:
> In addition to OpenAvnu, Renesas has a number of github repositories with what looks like a fairly
> complete media streaming system:

Is it a generic stack or a set of hacks for their HW?

> Although your SO_TXTIME proposal could certainly form the basis of an endpoint's implementation of Qbv, I
> think it is a stretch to consider it a Qbv implementation in itself, if that's what you mean by this.

No, that is not what I meant.  We need some minimal additional kernel
support in order to fully implement the TSN family of standards.  Of
course, the bulk will have to be done in user space.  It would be a
mistake to cram the stuff that belongs in userland into the kernel.

Looking at the table, and reading your descriptions of the state of
OpenAVB, I remained convinced that the kernel needs only three
additions:

1. SO_TXTIME
2. CBS Qdisc
3. ALSA support for DAC clock control (but that is another story)

> The proper interfaces for the Qbv configuration and managing of switch-level PTP timestamps are not yet
> in place, so there's nothing even at RFC stage to present yet, but Qbv-capable Linux-managed switch
> hardware is available and we hope to get some reusable code published even if it's not yet ready to be
> integrated in the kernel.

Right, configuring Qbv in an attached DSA switch needs its own
interface.

Regarding PHC support for DSA switches, I have something in the works
to be published soon.

> A bit of progress has been made since that was written, although it is true that it's still not
> quite complete and certainly not turnkey.

So OpenAVB is neither complete nor turnkey.  That was my impression,
too.

> Things are maybe a bit farther along than they seemed, but there is still important kernel work to be
> done to reduce the need for out-of-tree drivers and to get everyone on the same interfaces. I plan
> to be an active participant going forward.

You mentioned a couple of different kernel things you implemented.
I would encourage you to post the work already done.

Thanks,
Richard
