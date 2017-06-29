From: David Miller <davem@davemloft.net>
Subject: Re: [net-next v2 6/6] ixgbe: Add malicious driver detection support
Date: Thu, 29 Jun 2017 14:28:18 -0400 (EDT)
Message-ID: <20170629.142818.560549326785464904.davem@davemloft.net>
References: <CAJ3xEMgT62xt=TdFyY9vfRG+eOqvcLT+5m1WSGPtexygyrcB+w@mail.gmail.com>
        <87618083B2453E4A8714035B62D67992B3E89F1D@FMSMSX105.amr.corp.intel.com>
        <CAJ3xEMgAOMM3g0sqc6AfWLWf_VKwuHQGh_ZSYfmeQg=JotGbbg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: emil.s.tantilov@intel.com, jeffrey.t.kirsher@intel.com,
        paul.greenwalt@intel.com, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: gerlitz.or@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:44212 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753110AbdF2S2V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 14:28:21 -0400
In-Reply-To: <CAJ3xEMgAOMM3g0sqc6AfWLWf_VKwuHQGh_ZSYfmeQg=JotGbbg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Or Gerlitz <gerlitz.or@gmail.com>
Date: Wed, 28 Jun 2017 17:28:59 +0300

> On Wed, Jun 28, 2017 at 1:14 AM, Tantilov, Emil S
> <emil.s.tantilov@intel.com> wrote:
> 
>> Mainly because I am not sure that other (non-Intel) drivers will benefit from
>> such an option. In normal operation this functionality should not cause issues
>> and if it doesn't we may be able to deprecate the private flag in the future.
> 
> If you think this functionality makes sense any driver running over HW
> implementing
> it would like to be able to expose that and hence you better not use
> private flag.
> 
> Are we sure the trust UAPI can't be extended for that matter?

Yeah, we should probably make this a generic control if possible.
