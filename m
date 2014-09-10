From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Wed, 10 Sep 2014 10:28:25 -0700
Message-ID: <CAMEtUuyk7Kf3Eckqk1Z0JBQoNPTf87+Lm5KKV1ybOTxp-9B_Eg@mail.gmail.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
	<54100975.6030809@redhat.com>
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
In-Reply-To: <54100975.6030809@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 10, 2014 at 1:19 AM, Daniel Borkmann <dborkman@redhat.com> wrote:
>>
>>         In the future maps can have different types: hash, array, bloom
>> filter,
>>         radix-tree, but currently only hash type is supported:
>>         enum bpf_map_type {
>>            BPF_MAP_TYPE_UNSPEC,
>>            BPF_MAP_TYPE_HASH,
>>         };
>
>
> If we mention them here in the man page, users are going to request
> them, naturally. ;) So I'd just mention what we have, not what we do
> not yet have. But I'm wondering how much library boiler plate only
> for BPF we want to add in future, hopefully not most of what's in
> Corman ... ? ;)

:)
as cover letter says hash type was moved from this set to
later series, so it's implemented.
array and radix-tree are implemented as well, but not ready for
review yet. I have strong use cases for them.
Even two of the simplest examples for tracing (ex2 and ex3)
will benefit from 'array' type.
For bloomfiler type Chema had a strong use case as well.
I was assuming he will implement it sooner or later ;)
But, surely, I can drop future features from the manpage.
