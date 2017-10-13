From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [next-queue PATCH v7 4/6] net/sched: Introduce Credit Based Shaper (CBS) qdisc
Date: Fri, 13 Oct 2017 10:12:18 -0700
Message-ID: <87efq7m0p9.fsf@intel.com>
References: <20171013004005.17416-1-vinicius.gomes@intel.com> <20171013004005.17416-5-vinicius.gomes@intel.com> <1507862553.31614.53.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, jiri@resnulli.us,
        andre.guedes@intel.com, ivan.briano@intel.com,
        jesus.sanchez-palencia@intel.com, boon.leong.ong@intel.com,
        richardcochran@gmail.com, henrik@austad.us, levipearson@gmail.com,
        rodney.cummings@ni.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:19080 "EHLO mga01.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752120AbdJMRMZ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 13 Oct 2017 13:12:25 -0400
In-Reply-To: <1507862553.31614.53.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Eric Dumazet <eric.dumazet@gmail.com> writes:

[...]

>
> Your mixing of s64 and u64 is disturbing.
>
> do_div() handles u64, not s64.
>
> div64_s64() might be needed in place of do_div()

I wasn't very comfortable about the signal juggling either. Didn't know
about div64_s64(), looks much better. Will fix, thanks.


Cheers,
