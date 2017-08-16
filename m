From: Michael Ellerman <mpe@ellerman.id.au>
Subject: Re: [PATCH] bpf: Update sysctl documentation to list all supported architectures
Date: Wed, 16 Aug 2017 21:10:40 +1000
Message-ID: <8760dnu5sf.fsf@concordia.ellerman.id.au>
References: <1502860557-20247-1-git-send-email-mpe@ellerman.id.au> <5993FFC9.8010206@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, ast@kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <5993FFC9.8010206@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Daniel Borkmann <daniel@iogearbox.net> writes:

> Hi Michael,
>
> On 08/16/2017 07:15 AM, Michael Ellerman wrote:
>> The sysctl documentation states that the JIT is only available on
>> x86_64, which is no longer correct.
>>
>> Update the list to include all architectures that enable HAVE_CBPF_JIT
>> or HAVE_EBPF_JIT under some configuration.
>>
>> Signed-off-by: Michael Ellerman <mpe@ellerman.id.au>
>
> Thanks for the patch!
>
>>   Documentation/sysctl/net.txt | 5 +++--
>>   1 file changed, 3 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/sysctl/net.txt b/Documentation/sysctl/net.txt
>> index 14db18c970b1..f68356024d09 100644
>> --- a/Documentation/sysctl/net.txt
>> +++ b/Documentation/sysctl/net.txt
>> @@ -36,8 +36,9 @@ bpf_jit_enable
>>   --------------
>>
>>   This enables Berkeley Packet Filter Just in Time compiler.
>> -Currently supported on x86_64 architecture, bpf_jit provides a framework
>> -to speed packet filtering, the one used by tcpdump/libpcap for example.
>> +Currently supported on arm, arm64, mips, powerpc, s390, sparc and x86_64
>> +architectures, bpf_jit provides a framework to speed packet filtering, the one
>> +used by tcpdump/libpcap for example.
>
> Good point, could we actually make that as a bullet list and
> differentiate between cBPF and eBPF JITs, so that a user doesn't
> need to run git grep HAVE_{E,C}BPF_JIT to figure it out what the
> switch enables on the arch used? That would be great.

We could.

Does a user of the sysctl want/need to know the difference though? Or do
they just want to turn on "the JIT"?

cheers
