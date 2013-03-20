From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net-next 4/4] filter: add minimal BPF JIT emitted image
 disassembler
Date: Wed, 20 Mar 2013 09:50:41 +0100
Message-ID: <51497861.6020804@redhat.com>
References: <cover.1363699285.git.dborkman@redhat.com>  <8d8079d7a5cffe05eeb44a35cb5d7c3544a84f4f.1363699285.git.dborkman@redhat.com> <1363748314.31336.30.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	eric.dumazet@gmail.com, jasowang@redhat.com,
	Eric Dumazet <edumazet@google.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53475 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751418Ab3CTIuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Mar 2013 04:50:51 -0400
In-Reply-To: <1363748314.31336.30.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/20/2013 03:58 AM, Ben Hutchings wrote:
> On Tue, 2013-03-19 at 14:28 +0100, Daniel Borkmann wrote:
>> This is a minimal stand-alone user space helper, that allows for debugging or
>> verification of emitted BPF JIT images. This is in particular useful for
>> emitted opcode debugging, since minor bugs in the JIT compiler can be fatal.
>> The disassembler is architecture generic and uses libopcodes and libbfd.
> [...]
>> ---
>>   scripts/bpf_jit_disasm.c | 216 +++++++++++++++++++++++++++++++++++++++++++++++
>>   1 file changed, 216 insertions(+)
>>   create mode 100644 scripts/bpf_jit_disasm.c
> [...]
>
> This might belong in tools.  scripts is mostly for build scripts now.

Ok, I thought this would be overkill, since it's just a small C program
(unlike perf, etc) and there are also other things present in scripts/
like Coccinelle scripts etc. But, sure we could do this. What would you
suggest? tools/net/bpf_jit_disasm.c?
