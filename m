From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v13 net-next 07/11] bpf: verifier (add ability to receive
 verification log)
Date: Fri, 19 Sep 2014 14:04:50 -0700
Message-ID: <CAMEtUux071cELLdoWs21WL0dqgdwj+O=P64aeXSfyUtFW9U69w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo@kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Daniel Borkmann <dborkman@redhat.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 18, 2014 at 10:28 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
> On 09/18/2014 05:24 PM, Alexei Starovoitov wrote:
> ...
>>
>> solve or not. If we decide to solve it, we need to have
>> a plan to solve it all the way. Partial fix for size of bpf_attr
>> is not a plan. It's something that is not addressing the problem
>> completely. Little bit of help is not useful for userspace. It
>> would need to deal with new types, verifier differences and
>> other things that I mentioned earlier.
>
>
> Hm, I don't think it would be a strict requirement to solve it
> all the way, and I think that perf_event_open() with perf_copy_attr()
> is not trying to do so either. It, however, is trying on a ``best
> effort basis'' to still load something if new features are unused
> by the binary (I guess you saw the comment in perf_copy_attr()).
>
> Iff, e.g. due to new types we fail at the verifier stage, sure,
> that's life since we only have backwards-compatible guarantee,
> but in case we tried to use features we support, we're still able
> to load the eBPF program while right now, we're rejecting it right
> up-front. That's just my $0.02 ...

David,

the 'changes requested' status means that you want me to
address this forward compatibility now instead of later?
Or something else?
I don't want to second guess, respin and spam people
unnecessary. In this case I don't think Daniel is insisting
on doing it in this patch set. The things discussed above
are not urgent. Unless I'm missing something.
Please clarify.

Thanks
