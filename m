From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH v9 tip 0/9] tracing: attach eBPF programs to kprobes
Date: Sat, 21 Mar 2015 00:08:12 -0400
Message-ID: <20150321000812.606ef8cb@grimm.local.home>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alexei Starovoitov <ast@plumgrid.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cdptpa-outbound-snat.email.rr.com ([107.14.166.227]:31750 "EHLO
	cdptpa-oedge-vip.email.rr.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751236AbbCUEH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 21 Mar 2015 00:07:28 -0400
In-Reply-To: <1426894210-27441-1-git-send-email-ast@plumgrid.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 20 Mar 2015 16:30:01 -0700
Alexei Starovoitov <ast@plumgrid.com> wrote:

> Hi Ingo,
> 
> I think it's good to go.
> Patch 1 is already in net-next. Patch 3 depends on it.
> I'm assuming it's not going to be a problem during merge window.
> Patch 3 will have a minor conflict in uapi/linux/bpf.h in linux-next,
> since net-next has added new lines to the bpf_prog_type and bpf_func_id enums.
> I'm assuming it's not a problem either.
> 
> V8->V9:
> - fixed comment style and allowed ispunct after %p
> - added Steven's Reviewed-by. Thanks Steven!

Hi Ingo,

I'm fine with this series, so don't let me hold it up from going into
your tree.

Thanks,

-- Steve
