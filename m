From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH v2 tip 0/7] 64-bit BPF insn set and tracing filters
Date: Thu, 13 Feb 2014 23:44:16 +0100
Message-ID: <52FD4AC0.7090502@redhat.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com>	<52F3670D.5090608@redhat.com> <CAMEtUuza3NuM7L0RnVVgU-MTfjE2M==8wb4UY2TAo0Pg6DKZqA@mail.gmail.com> <52FD47F9.2090907@zytor.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@plumgrid.com>,
	Ingo Molnar <mingo@kernel.org>,
	"David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Thomas Gleixner <tglx@linutronix.de>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Tom Zanussi <tom.zanussi@linux.intel.com>,
	Jovi Zhangwei <jovi.zhangwei@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andrew Morton <akpm@linux-foundation.org>,
	Frederic Weisbecker <fweisbec@gmail.com>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Pekka Enberg <penberg@iki.fi>,
	Arjan van de Ven <arjan@infradead.org>,
	Christoph Hellwig <hch@infradead.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "H. Peter Anvin" <hpa@zytor.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <52FD47F9.2090907@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/13/2014 11:32 PM, H. Peter Anvin wrote:
> On 02/06/2014 05:20 PM, Alexei Starovoitov wrote:
>>
>> I believe that old BPF outlived itself and BPF64 should
>> replace it in all current use cases plus a lot more.
>> It just cannot happen at once.
>> BPF64 can come in. bpf32->bpf64 converter functioning.
>> JIT from bpf64->aarch64 and may be sparc64 needs to be in place.
>> Then old bpf can fade away.
>
> I don't think that is doable any time soon.  Right now pretty much all
> mobile devices, for example, are 32 bits and they really want to use
> syscall filtering for security.  Performance matters greatly there.

Well, if that would be the case, then seccomp would have had JIT support
long ago. ;-) Right now BPF filters with seccomp are not JIT compiled
for _any_ architecture.

> As such, 32-bit JIT support is going to be very important for a long
> time to come.

True, I think that pretty much depends if we can manage to find a way
to cleanly integrate it into net/core/filter.c while still supporting
the old instructions as I've mentioned earlier.

> 	-hpa
>
>
