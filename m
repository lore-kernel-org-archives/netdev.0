From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH v2 0/5] MIPS: BPF: JIT fixes and improvements.
Date: Tue, 14 Mar 2017 17:34:02 -0700
Message-ID: <1d09f001-aa15-e3bf-be85-a13b1132a12a@caviumnetworks.com>
References: <20170314212144.29988-1-david.daney@cavium.com>
 <20170314.172937.1289357366273291363.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, james.hogan@imgtec.com, ast@kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        steven.hill@cavium.com
To: David Miller <davem@davemloft.net>, david.daney@cavium.com,
        ralf@linux-mips.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170314.172937.1289357366273291363.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/14/2017 05:29 PM, David Miller wrote:
> From: David Daney <david.daney@cavium.com>
> Date: Tue, 14 Mar 2017 14:21:39 -0700
>
>> Changes from v1:
>>
>>   - Use unsigned access for SKF_AD_HATYPE
>>
>>   - Added three more patches for other problems found.
>>
>>
>> Testing the BPF JIT on Cavium OCTEON (mips64) with the test-bpf module
>> identified some failures and unimplemented features.
>>
>> With this patch set we get:
>>
>>      test_bpf: Summary: 305 PASSED, 0 FAILED, [85/297 JIT'ed]
>>
>> Both big and little endian tested.
>>
>> We still lack eBPF support, but this is better than nothing.
>
> What tree are you targetting with these changes?  Do you expect
> them to go via the MIPS or the net-next tree?
>
> Please be explicit about this in the future.
>

Sorry I didn't mention it.

My expectation is that Ralf would merge it via the MIPS tree, as it is 
fully contained within arch/mips/*


David Daney

> Thank you.
>
