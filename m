From: Vinicius Costa Gomes <vinicius.gomes@intel.com>
Subject: Re: [next-queue PATCH v5 3/5] net/sched: Introduce Credit Based Shaper (CBS) qdisc
Date: Wed, 11 Oct 2017 14:38:46 -0700
Message-ID: <87vajlmkk9.fsf@intel.com>
References: <20171011004400.14946-1-vinicius.gomes@intel.com> <20171011004400.14946-4-vinicius.gomes@intel.com> <20171011065809.GB2039@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain
Cc: netdev@vger.kernel.org, intel-wired-lan@lists.osuosl.org,
        jhs@mojatatu.com, xiyou.wangcong@gmail.com, andre.guedes@intel.com,
        ivan.briano@intel.com, jesus.sanchez-palencia@intel.com,
        boon.leong.ong@intel.com, richardcochran@gmail.com,
        henrik@austad.us, levipearson@gmail.com, rodney.cummings@ni.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga06.intel.com ([134.134.136.31]:21015 "EHLO mga06.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1750718AbdJKVis (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 11 Oct 2017 17:38:48 -0400
In-Reply-To: <20171011065809.GB2039@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> writes:

[...]

>>+struct tc_cbs_qopt_offload {
>>+	u8 enable;
>>+	s32 queue;
>>+	s32 hicredit;
>>+	s32 locredit;
>>+	s32 idleslope;
>>+	s32 sendslope;
>
> Please introduce the qdisc in one patch, then offload it in second. That
> is what I requested already. 2 patches please.
>
> [...]

Will move these declarations to the offload patch.

>
>
>>+static struct Qdisc_ops cbs_qdisc_ops __read_mostly = {
>>+	.next		=	NULL,
>
> It is already 0, no need to re-init.

Will fix.


Cheers,
