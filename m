From: Jesus Sanchez-Palencia <jesus.sanchez-palencia@intel.com>
Subject: Re: TSN Scorecard, was Re: [RFC net-next 0/5] TSN: Add qdisc-based
 config interfaces for traffic shapers
Date: Wed, 20 Sep 2017 14:29:51 -0700
Message-ID: <b16a7f61-0be3-b91c-990e-b1c06ca159df@intel.com>
References: <20170918081248.txhars53icbqsvld@localhost>
 <20170920051754.21745-1-levipearson@gmail.com>
 <20170920054919.jtqckuybsu42tvpk@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        vinicius.gomes@intel.com, andre.guedes@intel.com,
        ivan.briano@intel.com, boon.leong.ong@intel.com, jhs@mojatatu.com,
        xiyou.wangcong@gmail.com, jiri@resnulli.us, henrik@austad.us
To: Richard Cochran <richardcochran@gmail.com>, levipearson@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:38150 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751378AbdITVgi (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 20 Sep 2017 17:36:38 -0400
In-Reply-To: <20170920054919.jtqckuybsu42tvpk@localhost>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,


On 09/19/2017 10:49 PM, Richard Cochran wrote:
(...)

> 
> No, that is not what I meant.  We need some minimal additional kernel
> support in order to fully implement the TSN family of standards.  Of
> course, the bulk will have to be done in user space.  It would be a
> mistake to cram the stuff that belongs in userland into the kernel.
> 
> Looking at the table, and reading your descriptions of the state of
> OpenAVB, I remained convinced that the kernel needs only three
> additions:
> 
> 1. SO_TXTIME
> 2. CBS Qdisc
> 3. ALSA support for DAC clock control (but that is another story)


We'll be posting the CBS v1 series for review soon.

The current SO_TXTIME RFC for the purpose of Launchtime looks great, and we are
looking forward for the v1 + its companion qdisc so we can test / review and
provide feedback.

We are still under the impression that a config interface for HW offload of Qbv
/ Qbu config will be needed, but we'll be deferring the 'taprio' proposal until
there are NICs (end stations) that support these standards available. We can
revisit it if that ever happens, and if it's still needed, but then taking into
account SO_TXTIME (and its related qdisc).

Thanks everyone for all the feedback so far.

Regards,
Jesus
