From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next 1/2] perf, bpf: add support for HW_CACHE and RAW
 events
Date: Tue, 23 May 2017 07:38:08 -0700
Message-ID: <b25f4d02-70c1-43ce-8bf1-9b89e573add6@fb.com>
References: <20170522224840.810121-1-ast@fb.com>
 <20170522224840.810121-2-ast@fb.com>
 <20170523074247.esnr4fj2squn4w2d@hirez.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>,
        Brendan Gregg <bgregg@netflix.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Teng Qin <qinteng@fb.com>, <netdev@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, <kernel-team@fb.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170523074247.esnr4fj2squn4w2d@hirez.programming.kicks-ass.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 5/23/17 12:42 AM, Peter Zijlstra wrote:
> On Mon, May 22, 2017 at 03:48:39PM -0700, Alexei Starovoitov wrote:
>> From: Teng Qin <qinteng@fb.com>
>>
>> This commit adds support for attach BPF program to RAW and HW_CACHE type
>> events, and support for read HW_CACHE type event counters in BPF
>> program. Existing code logic already supports them, so this commit is
>> just update Enum value checks.
>
> So what I'm missing is why they were not supported previously, and what
> changed to allow it now.

that code path simply wasn't tested previously. Nothing changed on
bpf side and on perf side.
Why it wasn't added on day one? There was no demand. Now people
use bpf more and more and few folks got confused that these types
of perf events were not supported, hence we're adding it.
