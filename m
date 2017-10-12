From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [next-queue PATCH v6 3/5] net/sched: Introduce Credit Based Shaper (CBS) qdisc
Date: Thu, 12 Oct 2017 10:50:07 -0700
Message-ID: <87mv4wmf1s.fsf@intel.com>
References: <20171012005449.26533-1-vinicius.gomes@intel.com> <20171012005449.26533-4-vinicius.gomes@intel.com> <1507771972.31614.41.camel@edumazet-glaptop3.roam.corp.google.com>
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
Received: from mga09.intel.com ([134.134.136.24]:20125 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750992AbdJLRuJ (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 12 Oct 2017 13:50:09 -0400
In-Reply-To: <1507771972.31614.41.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Eric Dumazet <eric.dumazet@gmail.com> writes:

> On Wed, 2017-10-11 at 17:54 -0700, Vinicius Costa Gomes wrote:
>> This queueing discipline implements the shaper algorithm defined by
>> the 802.1Q-2014 Section 8.6.8.2 and detailed in Annex L.
>
> ...
>
>> +static s64 delay_from_credits(s64 credits, s32 slope)
>> +{
>> +	s64 rate = slope * BYTES_PER_KBIT;
>> +
>> +	if (unlikely(rate == 0))
>> +		return S64_MAX;
>> +
>> +	return ((-credits * NSEC_PER_SEC) / rate);
>> +}
>
> Have you tried to compile this on 32bit arch ?
>
> make ARCH=i386

Will be fixed on v7.


Cheers,
