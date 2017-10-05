From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next v6 0/4] bpf: add two helpers to read perf event
 enabled/running time
Date: Thu, 05 Oct 2017 12:36:45 +0200
Message-ID: <59D60B3D.4040702@iogearbox.net>
References: <20171002224218.3181418-1-yhs@fb.com> <20171004.160056.801262768847050741.davem@davemloft.net> <20171005083437.v3yfluazdy5du7pi@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: yhs@fb.com, rostedt@goodmis.org, ast@fb.com,
        netdev@vger.kernel.org, kernel-team@fb.com
To: Peter Zijlstra <peterz@infradead.org>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42405 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751721AbdJEKgy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 5 Oct 2017 06:36:54 -0400
In-Reply-To: <20171005083437.v3yfluazdy5du7pi@hirez.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/05/2017 10:34 AM, Peter Zijlstra wrote:
> On Wed, Oct 04, 2017 at 04:00:56PM -0700, David Miller wrote:
>> From: Yonghong Song <yhs@fb.com>
>> Date: Mon, 2 Oct 2017 15:42:14 -0700
>>
>>> [Dave, Peter,
>>>
>>>   Previous communcation shows that this patch may potentially have
>>>   merge conflict with upcoming tip changes in the next merge window.
>>>
>>>   Could you advise how this patch should proceed?
>>>
>>>   Thanks!
>>> ]
>>
>> Indeed, Peter how do you want to handle this?
>
> I think Alexei suggested that we merge the one patch in two branches and
> let git sort it out. I _think_ I've done something similar before and it
> worked.

Sounds good, we did something like this in the past as well I recall,
so lets make first patch isolated to only touch perf event area so
it can go into both trees, and the remaining pieces only for BPF bits
for net-next.
