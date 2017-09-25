From: Yonghong Song <yhs@fb.com>
Subject: Re: [PATCH net-next v5 1/4] bpf: add helper bpf_perf_event_read_value
 for perf event array map
Date: Mon, 25 Sep 2017 08:41:04 -0700
Message-ID: <56191a53-33cf-c1b3-e482-9d575bafb0ef@fb.com>
References: <20170920060935.1102268-1-yhs@fb.com>
 <20170920060935.1102268-2-yhs@fb.com>
 <20170920172651.zx4nfmj2lpgxzubq@hirez.programming.kicks-ass.net>
 <20170920.160707.932591498085219317.davem@davemloft.net>
 <b9753171-8e70-92f2-9852-8d3a33f2c07c@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <rostedt@goodmis.org>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Alexei Starovoitov <ast@fb.com>,
        David Miller <davem@davemloft.net>, <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:41884 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933349AbdIYPmM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2017 11:42:12 -0400
In-Reply-To: <b9753171-8e70-92f2-9852-8d3a33f2c07c@fb.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 9/21/17 8:15 AM, Alexei Starovoitov wrote:
> On 9/20/17 4:07 PM, David Miller wrote:
>> From: Peter Zijlstra <peterz@infradead.org>
>> Date: Wed, 20 Sep 2017 19:26:51 +0200
>>
>>> Dave, could we have this in a topic tree of sorts, because I have a
>>> pending series to rework all the timekeeping and it might be nice to not
>>> have sfr run into all sorts of conflicts.
>>
>> If you want to merge it into your tree that's fine.
>>
>> But it means that any further development done on top of this
>> work will need to go via you as well.
> 
> can we merge this set of patches into both net-next and tip ?
> We did such tricks in the past to avoid merge conflicts and
> everything went fine during merge window.

Hi, Peter,

Any suggestion for merging this patch? Alexei's idea sounds
reasonable?

Thanks,

Yonghong
