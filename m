From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH v11 net-next 12/12] bpf: mini eBPF library, test stubs
 and verifier testsuite
Date: Wed, 17 Sep 2014 23:59:58 +0200
Message-ID: <541A045E.3030206@redhat.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com> <1410325808-3657-13-git-send-email-ast@plumgrid.com> <54103776.3080706@redhat.com> <CAMEtUuzEQu30WiYprRcDBogJxxrDeNhvn=kF+z8cVvhR-vjTQg@mail.gmail.com> <54193542.6080101@redhat.com> <CAMEtUuzaCEX9RKDBMnQBZSHdTjjidp81myfSVVi4qQqtSGgtmw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuzaCEX9RKDBMnQBZSHdTjjidp81myfSVVi4qQqtSGgtmw-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/17/2014 06:17 PM, Alexei Starovoitov wrote:
> On Wed, Sep 17, 2014 at 12:16 AM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
>>
>> That actually still doesn't answer my question why the test stub
>> cannot live in lib/test_bpf where we have our actual testing
>> framework for eBPF/BPF, also since you exactly only build test_stub.c
>> when TEST_BPF is enabled which is the Kconfig for lib/test_bpf.
>
> multiple reasons:
> 1.
> lib/test_bpf.c is a module, whereas test_stub.c is kernel builtin.
>
> 2.
> I wasn't sure that reusing CONFIG_TEST_BPF for this
> purpose was a good idea. May be it's better to introduce
> CONFIG_BPF_VERIFIER_TEST_STUBS or something.
>
> 3.
> kernel/bpf/test_stubs.c can be removed once real tracing
> or socket use case is in.

Yes, please, lets go for point 3 at the very least.
