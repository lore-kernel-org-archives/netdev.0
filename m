From: Ingo Molnar <mingo@kernel.org>
Subject: Re: [PATCH net-next 0/2] split BPF out of core networking
Date: Sun, 1 Jun 2014 10:05:46 +0200
Message-ID: <20140601080546.GB29062@gmail.com>
References: <1401586941-4274-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Steven Rostedt <rostedt@goodmis.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	Chema Gonzalez <chema@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Thomas Gleixner <tglx@linutronix.de>,
	"H. Peter Anvin" <hpa@zytor.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1401586941-4274-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <ast@plumgrid.com> wrote:

> This patch set splits BPF out of core networking into generic component

>   net: filter: split filter.c into two files
>   net: filter: split BPF out of core networking
> 
>  arch/Kconfig           |    3 +-
>  include/linux/filter.h |    2 +
>  net/Kconfig            |    4 +
>  net/Makefile           |    1 +
>  net/bpf/Makefile       |    5 +
>  net/bpf/core.c         | 1063 ++++++++++++++++++++++++++++++++++++++++++++++++
>  net/core/filter.c      | 1023 +---------------------------------------------
>  7 files changed, 1079 insertions(+), 1022 deletions(-)
>  create mode 100644 net/bpf/Makefile
>  create mode 100644 net/bpf/core.c

I like the splitup, but please put it into lib/bpf/ or kernel/bpf/ to 
signal its 'generic', 'core' nature, to be used in many subsystems 
outside of networking.

Thanks,

	Ingo
