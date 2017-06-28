From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [net-next v2 6/6] ixgbe: Add malicious driver detection support
Date: Wed, 28 Jun 2017 17:28:59 +0300
Message-ID: <CAJ3xEMgAOMM3g0sqc6AfWLWf_VKwuHQGh_ZSYfmeQg=JotGbbg@mail.gmail.com>
References: <20170627085131.9831-1-jeffrey.t.kirsher@intel.com>
 <20170627085131.9831-7-jeffrey.t.kirsher@intel.com> <CAJ3xEMiEjGDUatUv47wNTfYPfCVo62+Jjs-xFU3ccN0iJm-5Gg@mail.gmail.com>
 <87618083B2453E4A8714035B62D67992B3E89EA6@FMSMSX105.amr.corp.intel.com>
 <CAJ3xEMgT62xt=TdFyY9vfRG+eOqvcLT+5m1WSGPtexygyrcB+w@mail.gmail.com> <87618083B2453E4A8714035B62D67992B3E89F1D@FMSMSX105.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: "Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>,
        David Miller <davem@davemloft.net>,
        "Greenwalt, Paul" <paul.greenwalt@intel.com>,
        Linux Netdev List <netdev@vger.kernel.org>,
        "nhorman@redhat.com" <nhorman@redhat.com>,
        "sassmann@redhat.com" <sassmann@redhat.com>,
        "jogreene@redhat.com" <jogreene@redhat.com>
To: "Tantilov, Emil S" <emil.s.tantilov@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f44.google.com ([209.85.218.44]:36627 "EHLO
        mail-oi0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751723AbdF1O3A (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Jun 2017 10:29:00 -0400
Received: by mail-oi0-f44.google.com with SMTP id p187so42763813oif.3
        for <netdev@vger.kernel.org>; Wed, 28 Jun 2017 07:29:00 -0700 (PDT)
In-Reply-To: <87618083B2453E4A8714035B62D67992B3E89F1D@FMSMSX105.amr.corp.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 28, 2017 at 1:14 AM, Tantilov, Emil S
<emil.s.tantilov@intel.com> wrote:

> Mainly because I am not sure that other (non-Intel) drivers will benefit from
> such an option. In normal operation this functionality should not cause issues
> and if it doesn't we may be able to deprecate the private flag in the future.

If you think this functionality makes sense any driver running over HW
implementing
it would like to be able to expose that and hence you better not use
private flag.

Are we sure the trust UAPI can't be extended for that matter?
