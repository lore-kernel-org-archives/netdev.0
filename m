From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v11 net-next 12/12] bpf: mini eBPF library, test stubs and
 verifier testsuite
Date: Wed, 17 Sep 2014 15:16:08 -0700
Message-ID: <CAMEtUuzWJpy+Xb_=WV=1tip3QZX_=ivs36=btMjWFYgYjkQgCA@mail.gmail.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
	<1410325808-3657-13-git-send-email-ast@plumgrid.com>
	<54103776.3080706@redhat.com>
	<CAMEtUuzEQu30WiYprRcDBogJxxrDeNhvn=kF+z8cVvhR-vjTQg@mail.gmail.com>
	<54193542.6080101@redhat.com>
	<CAMEtUuzaCEX9RKDBMnQBZSHdTjjidp81myfSVVi4qQqtSGgtmw@mail.gmail.com>
	<541A045E.3030206@redhat.com>
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
In-Reply-To: <541A045E.3030206@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 17, 2014 at 2:59 PM, Daniel Borkmann <dborkman@redhat.com> wrote:
>>
>> 3.
>> kernel/bpf/test_stubs.c can be removed once real tracing
>> or socket use case is in.
>
>
> Yes, please, lets go for point 3 at the very least.

agree. test_stubs is a way to have verifier testsuite
as the first ebpf user in this patch set.
There are multiple ways of connecting ebpf to tracing/sockets
and these discussions cannot happen all at once.
So test_stubs to some degree is scaffolding to bring
other pieces in place slowly with required due diligence.
I don't think there will be a need for test_stubs when
tracing+ebpf is in place. That's why I didn't introduce
special prog_type and map_type for it and instead used
'unspec' type which is invalid type and used for testing
temporarily.
verifier testsuite, of course, will stay. It will switch from
'unspec' type to real types when they're ready.
