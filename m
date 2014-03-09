From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v7 net-next 1/3] filter: add Extended BPF interpreter
 and converter
Date: Sun, 09 Mar 2014 12:11:46 -0700
Message-ID: <1394392306.20149.112.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1394320530-3508-1-git-send-email-ast@plumgrid.com>
	 <1394320530-3508-2-git-send-email-ast@plumgrid.com>
	 <1394376353.20149.96.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuyB9ZhvwU+Lv5UypXDbgAG02BgdRomF9nOef-GqNAxjww@mail.gmail.com>
	 <1394388699.20149.105.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAMEtUuwYUhA=CKRVxr-8_KdTqzoQVD1OtgayyxX3aO48CTcxZw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <dborkman@redhat.com>,
	Ingo Molnar <mingo@kernel.org>, Will Drewry <wad@chromium.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Hagen Paul Pfeifer <hagen@jauu.net>,
	Jesse Gross <jesse@nicira.com>,
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
	LKML <linux-kernel@vger.kernel.org>, netdev@vger.k
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuwYUhA=CKRVxr-8_KdTqzoQVD1OtgayyxX3aO48CTcxZw@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2014-03-09 at 11:57 -0700, Alexei Starovoitov wrote:

> In sk_run_filter_ext() I used "u64 stack[64];", but "u64 stack[60];" is
> safe too, but I didn't want to go into extensive explanation
> of 'magic' 60 number in the first patch, so I just rounded it to 64.
> Since now you understand, I can make it stack[60] now :)

My point was : You should not use 64 or 60 in the C code.

I should not have to ask you why it is safe.

It should be obvious just reading the source code. And so far it is not.

Thats why we use macros and comments at the macro definition.
