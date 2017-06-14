From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH 0/4] bpf: Changes needed (or desired) for MIPS support
Date: Wed, 14 Jun 2017 08:54:03 -0700
Message-ID: <e17ffbca-f11f-5617-3188-a7eb82b03ed3@caviumnetworks.com>
References: <20170613234938.4823-1-david.daney@cavium.com>
 <594081CA.3060801@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <594081CA.3060801@iogearbox.net>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/13/2017 05:22 PM, Daniel Borkmann wrote:
> On 06/14/2017 01:49 AM, David Daney wrote:
>> This is a grab bag of changes to the bpf testing infrastructure I
>> developed working on MIPS eBPF JIT support.  The change to
>> bpf_jit_disasm is probably universally beneficial, the others are more
>> MIPS specific.
> 
> I think these could go independently through net-next tree?

Yes, if davem is happy with them, I think that makes sense that he take 
them via net-next.

David Daney

> 
> Thanks,
> Daniel
> 
>> David Daney (4):
>>    tools: bpf_jit_disasm:  Handle large images.
>>    test_bpf: Add test to make conditional jump cross a large number of
>>      insns.
>>    bpf: Add MIPS support to samples/bpf.
>>    samples/bpf: Fix tracex5 to work with MIPS syscalls.
>>
>>   lib/test_bpf.c             | 32 ++++++++++++++++++++++++++++++++
>>   samples/bpf/Makefile       | 13 +++++++++++++
>>   samples/bpf/bpf_helpers.h  | 13 +++++++++++++
>>   samples/bpf/syscall_nrs.c  | 12 ++++++++++++
>>   samples/bpf/tracex5_kern.c | 11 ++++++++---
>>   tools/net/bpf_jit_disasm.c | 37 ++++++++++++++++++++++++++-----------
>>   6 files changed, 104 insertions(+), 14 deletions(-)
>>   create mode 100644 samples/bpf/syscall_nrs.c
>>
> 
