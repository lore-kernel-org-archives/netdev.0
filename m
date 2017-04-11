From: David Daney <ddaney@caviumnetworks.com>
Subject: Re: [PATCH] tools: bpf_jit_disasm: Add option to dump JIT image to a
 file.
Date: Tue, 11 Apr 2017 16:11:17 -0700
Message-ID: <13a47f21-4459-04ef-a817-a6473c9b8f52@caviumnetworks.com>
References: <20170411213052.7337-1-david.daney@cavium.com>
 <58ED508B.9010005@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        David Daney <david.daney@cavium.com>,
        Alexei Starovoitov <ast@kernel.org>, netdev@vger.kernel.org,
        "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <58ED508B.9010005@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/11/2017 02:54 PM, Daniel Borkmann wrote:
> On 04/11/2017 11:30 PM, David Daney wrote:
>> When debugging the JIT on an embedded platform or cross build
>> environment, libbfd may not be available, making it impossible to run
>> bpf_jit_disasm natively.
>>
>> Add an option to emit a binary image of the JIT code to a file.  This
>> file can then be disassembled off line.  Typical usage in this case
>> might be (pasting mips64 dmesg output to cat command):
>>
>>     $ cat > jit.raw
>>     $ bpf_jit_disasm -f jit.raw -O jit.bin
>>     $ mips64-linux-gnu-objdump -D -b binary -m mips:isa64r2 -EB jit.bin
>>
>> Signed-off-by: David Daney <david.daney@cavium.com>
>
> Seems good, we could at some point also add an -I jit.bin option
> if needed for offline analysis/comparison instead of using -f
> plain text.
>

FWIW:  The objdump incantation in the changelog does just about the same 
disassembly as the bpf_jit_disasm internal implementation.

> Thanks!
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
