From: Hagen Paul Pfeifer <hagen@jauu.net>
Subject: Re: [PATCH v4 net-next 1/3] Extended BPF interpreter and converter
Date: Tue, 4 Mar 2014 14:28:24 +0000
Message-ID: <20140304142824.GA1083@localhost.localdomain>
References: <1393910304-4004-1-git-send-email-ast@plumgrid.com>
 <1393910304-4004-2-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniel Borkmann <dborkman@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>, Jesse Gross <jesse@nicira.com>,
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
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1393910304-4004-2-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

If all issues raised by Daniel are addresed:

Acked-by: Hagen Paul Pfeifer <hagen@jauu.net>

But ...

>Future work:
>
>0. seccomp
>
>1. add extended BPF JIT for x86_64
>
>2. add inband old/new demux and extended BPF verifier, so that new programs
>   can be loaded through old sk_attach_filter() and sk_unattached_filter_create()
>   interfaces
>
>3. tracing filters systemtap-like with extended BPF
>
>4. OVS with extended BPF
>
>5. nftables with extended BPF

... this is shit (not your fault). (Jitted) BPF envolved into a direction
which is just not the right way to do it. You try to fix things, bypass
architectural shortcomings of BPF, perf issues because and so on.

The right direction is to write a new general purpose in-kernel interpreter
from scratch. Capability layers should provide an compatible API for BPF and
seccomp. You have the knowledge to do exactly this, you nearly already did
this - you should start this undertake!

-- 
Hagen Paul Pfeifer
