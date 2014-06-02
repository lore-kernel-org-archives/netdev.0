From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH v2 net-next 0/2] split BPF out of core networking
Date: Mon, 02 Jun 2014 19:04:38 +0200
Message-ID: <538CAEA6.4060307@redhat.com>
References: <1401692506-7796-1-git-send-email-ast@plumgrid.com> <538C3C94.3080206@redhat.com> <CAMEtUuzkjZCsReWH9cZs8AU0mJjZH9YOdCBTWusxe6-NZ9mQ=g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Ingo Molnar <mingo@kernel.org>,
	Steven Rostedt <rostedt@goodmis.org>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Kees Cook <keescook@chromium.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuzkjZCsReWH9cZs8AU0mJjZH9YOdCBTWusxe6-NZ9mQ=g@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 06/02/2014 05:41 PM, Alexei Starovoitov wrote:
...
> Glad you brought up this point :)
> 100% agree that current double verification done by seccomp is far from
> being generic and quite hard to maintain, since any change done to
> classic BPF verifier needs to be thought through from seccomp_check_filter()
> perspective as well.

Glad we're on the same page.

> BPF's input context, set of allowed calls need to be expressed in a generic way.
> Obviously this split by itself won't make classic BPF all of a sudden generic.
> It rather defines a boundary of eBPF core.

Note, I'm not at all against using it in tracing, I think it's probably
a good idea, but shouldn't we _first_ think about how to overcome such
deficits as above by improving upon its in-kernel API design, thus to
better prepare it to be generic? I feel this step is otherwise just
skipped and quickly 'hacked' around ... ;)
