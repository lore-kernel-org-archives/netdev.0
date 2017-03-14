From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH v2 0/5] MIPS: BPF: JIT fixes and improvements.
Date: Tue, 14 Mar 2017 15:35:59 -0700
Message-ID: <2d6881a7-9a1d-f018-f0dc-62a5a61020bc@caviumnetworks.com>
References: <20170314212144.29988-1-david.daney@cavium.com>
 <58C86EC3.9010406@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
        "Steven J. Hill" <steven.hill@cavium.com>
To: Daniel Borkmann <daniel@iogearbox.net>,
        David Daney <david.daney@cavium.com>,
        linux-mips@linux-mips.org, ralf@linux-mips.org,
        James Hogan <james.hogan@imgtec.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58C86EC3.9010406@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/14/2017 03:29 PM, Daniel Borkmann wrote:
> On 03/14/2017 10:21 PM, David Daney wrote:
>> Changes from v1:
>>
>>    - Use unsigned access for SKF_AD_HATYPE
>>
>>    - Added three more patches for other problems found.
>>
>>
>> Testing the BPF JIT on Cavium OCTEON (mips64) with the test-bpf module
>> identified some failures and unimplemented features.
>
> Nice, thanks for working on this! If you see specific test
> cases for the JIT missing, please also feel free to extend
> the test_bpf suite, so this gets exposed further to other
> JITs, too.
>
>> With this patch set we get:
>>
>>       test_bpf: Summary: 305 PASSED, 0 FAILED, [85/297 JIT'ed]
>>
>> Both big and little endian tested.
>>
>> We still lack eBPF support, but this is better than nothing.
>
> Any future plans on this one?

Yes, my plan is to fully implement eBPF support for 64-bit MIPS, let's 
see if I get enough time to do it.

David.
