From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next v5 1/4] bpf: add helper bpf_perf_event_read_value
 for perf event array map
Date: Thu, 21 Sep 2017 08:15:39 -0700
Message-ID: <b9753171-8e70-92f2-9852-8d3a33f2c07c@fb.com>
References: <20170920060935.1102268-1-yhs@fb.com>
 <20170920060935.1102268-2-yhs@fb.com>
 <20170920172651.zx4nfmj2lpgxzubq@hirez.programming.kicks-ass.net>
 <20170920.160707.932591498085219317.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <yhs@fb.com>, <rostedt@goodmis.org>, <daniel@iogearbox.net>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: David Miller <davem@davemloft.net>, <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35120 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1751726AbdIUPQb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 11:16:31 -0400
In-Reply-To: <20170920.160707.932591498085219317.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 9/20/17 4:07 PM, David Miller wrote:
> From: Peter Zijlstra <peterz@infradead.org>
> Date: Wed, 20 Sep 2017 19:26:51 +0200
>
>> Dave, could we have this in a topic tree of sorts, because I have a
>> pending series to rework all the timekeeping and it might be nice to not
>> have sfr run into all sorts of conflicts.
>
> If you want to merge it into your tree that's fine.
>
> But it means that any further development done on top of this
> work will need to go via you as well.

can we merge this set of patches into both net-next and tip ?
We did such tricks in the past to avoid merge conflicts and
everything went fine during merge window.
