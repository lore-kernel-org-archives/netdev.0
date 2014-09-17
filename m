From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v11 net-next 12/12] bpf: mini eBPF library, test stubs and
 verifier testsuite
Date: Wed, 17 Sep 2014 09:17:41 -0700
Message-ID: <CAMEtUuzaCEX9RKDBMnQBZSHdTjjidp81myfSVVi4qQqtSGgtmw@mail.gmail.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
	<1410325808-3657-13-git-send-email-ast@plumgrid.com>
	<54103776.3080706@redhat.com>
	<CAMEtUuzEQu30WiYprRcDBogJxxrDeNhvn=kF+z8cVvhR-vjTQg@mail.gmail.com>
	<54193542.6080101@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linuxfoundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linuxfoundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Daniel Borkmann <dborkman@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <54193542.6080101@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 17, 2014 at 12:16 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>
>
> That actually still doesn't answer my question why the test stub
> cannot live in lib/test_bpf where we have our actual testing
> framework for eBPF/BPF, also since you exactly only build test_stub.c
> when TEST_BPF is enabled which is the Kconfig for lib/test_bpf.

multiple reasons:
1.
lib/test_bpf.c is a module, whereas test_stub.c is kernel builtin.

2.
I wasn't sure that reusing CONFIG_TEST_BPF for this
purpose was a good idea. May be it's better to introduce
CONFIG_BPF_VERIFIER_TEST_STUBS or something.

3.
kernel/bpf/test_stubs.c can be removed once real tracing
or socket use case is in.
