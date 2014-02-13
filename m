From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [RFC PATCH v2 tip 0/7] 64-bit BPF insn set and tracing filters
Date: Thu, 13 Feb 2014 23:55:52 +0100
Message-ID: <52FD4D78.4050709@redhat.com>
References: <1391649046-4383-1-git-send-email-ast@plumgrid.com>	<52F3670D.5090608@redhat.com> <CAMEtUuza3NuM7L0RnVVgU-MTfjE2M==8wb4UY2TAo0Pg6DKZqA@mail.gmail.com> <52FD47F9.2090907@zytor.com> <52FD4AC0.7090502@redhat.com> <52FD4B97.9020306@zytor.com>
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
In-Reply-To: <52FD4B97.9020306@zytor.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/13/2014 11:47 PM, H. Peter Anvin wrote:
> On 02/13/2014 02:44 PM, Daniel Borkmann wrote:
>>
>> Well, if that would be the case, then seccomp would have had JIT support
>> long ago. ;-) Right now BPF filters with seccomp are not JIT compiled
>> for _any_ architecture.
>
> Really, I was under the impression there were.  They *should be*, that
> was an important concept in the development of the seccomp filters.

$ git grep -n BPF_S_ANC_SECCOMP_LD_W
include/linux/filter.h:153:     BPF_S_ANC_SECCOMP_LD_W,
kernel/seccomp.c:136:                   ftest->code = BPF_S_ANC_SECCOMP_LD_W;
net/core/filter.c:389:          case BPF_S_ANC_SECCOMP_LD_W:
net/core/filter.c:812:          [BPF_S_ANC_SECCOMP_LD_W] = BPF_LD|BPF_B|BPF_ABS,

Afaik, there had been attempts to support it, but had flaws in it.

> 	-hpa
>
