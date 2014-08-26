From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH v6 net-next 4/6] bpf: enable bpf syscall on x64 and i386
Date: Tue, 26 Aug 2014 09:46:55 +0200
Message-ID: <20140826074655.GB19799@gmail.com>
References: <1409014858-1410-1-git-send-email-ast@plumgrid.com>
 <1409014858-1410-5-git-send-email-ast@plumgrid.com>
 <20140825205201.10ac5ee3@uryu.home.lan>
 <CAMEtUuxicvHsEQ59CeG2kmLW0b4TQ9ExfDkKo2kktH-t8x5tBg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Brendan Gregg <brendan.d.gregg@gmail.com>,
	Namhyung Kim <namhyung@kernel.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <CAMEtUuxicvHsEQ59CeG2kmLW0b4TQ9ExfDkKo2kktH-t8x5tBg@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> On Mon, Aug 25, 2014 at 8:52 PM, Stephen Hemminger
> <stephen@networkplumber.org> wrote:
> > Per discussion at Kernel Summit. Every new syscall requires
> > a manual page and test programs. We have had too many new syscalls
> > that are DOA.
> 
> There is verifier testsuite that is testing eBPF verifier from userspace
> via bpf syscall. Also there are multiple examples and libbpf.
> I think test coverage for bpf syscall is quite substantial already.

This is in tools/bpf/, right?

Thanks,

	Ingo
