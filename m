From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH RFC] sparc64: eBPF JIT
Date: Fri, 21 Apr 2017 18:50:34 +0200
Message-ID: <58FA385A.2020508@iogearbox.net>
References: <20170416.233825.1748421481008153466.davem@davemloft.net>   <58F50D13.3090001@iogearbox.net> <20170421.124640.1134810340055330244.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: sparclinux@vger.kernel.org, netdev@vger.kernel.org, ast@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <sparclinux-owner@vger.kernel.org>
In-Reply-To: <20170421.124640.1134810340055330244.davem@davemloft.net>
Sender: sparclinux-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/21/2017 06:46 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Mon, 17 Apr 2017 20:44:35 +0200
>
>> There is samples/bpf/sockex3_kern.c, which exercises it. To
>> run it, it would be (clang/llvm needed due to BPF backend not
>> available in gcc):
>>
>> # cd samples/bpf
>> # make
>> # ./sockex3
>> IP     src.port -> dst.port               bytes      packets
>> 127.0.0.1.12865 -> 127.0.0.1.49711          148            2
>> 127.0.0.1.49711 -> 127.0.0.1.12865          108            2
>> [...]
>>
>> Inside parse_eth_proto(), it will do tail calls based on the
>> eth protocol. Over time, we'll move such C based tests over to
>> tools/testing/selftests/bpf/.
>
> Ok, after a lot of work setting up an LLVM/CLANG environment and other
> things, I implemented tail call support and got this working.
>
> Thanks for the pointers.

Awesome, thanks!
