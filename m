From: He Kuang <hekuang@huawei.com>
Subject: Re: [PATCH v3 linux-trace 1/8] tracing: attach eBPF programs to tracepoints
 and syscalls
Date: Mon, 16 Feb 2015 19:26:46 +0800
Message-ID: <54E1D3F6.3040500@huawei.com>
References: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@kernel.org>, Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	Linux API <linux-api@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>, <wangnan0@huawei.com>
To: Alexei Starovoitov <ast@plumgrid.com>,
	Steven Rostedt <rostedt@goodmis.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAMEtUuzY_Po=WtFEFg1aqzJ8dEF4rHGcWDsaS44KYgACMNPPgA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi, Alexei

Another suggestion on bpf syscall interface. Currently, BPF +
syscalls/kprobes depends on CONFIG_BPF_SYSCALL. In kernel used on
commercial products, CONFIG_BPF_SYSCALL is probably disabled, in this
case, bpf bytecode cannot be loaded to the kernel.

If we turn the functionality of BPF_SYSCALL into a loadable module, then
we can use it without any dependencies on the kernel. What about change
bpf syscall to a /dev node or /sys file which can be exported by a
kernel module?
