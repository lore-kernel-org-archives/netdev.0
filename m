From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v9 tip 5/9] tracing: allow BPF programs to call bpf_trace_printk()
Date: Sun, 22 Mar 2015 11:05:41 -0700
Message-ID: <550F0475.7020206@plumgrid.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com> <1426894210-27441-6-git-send-email-ast@plumgrid.com> <20150322111040.GA18695@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150322111040.GA18695-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/22/15 4:10 AM, Ingo Molnar wrote:
>
> * Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>
>> +static const struct bpf_func_proto bpf_trace_printk_proto = {
>> +	.func = bpf_trace_printk,
>> +	.gpl_only = true,
>> +	.ret_type = RET_INTEGER,
>> +	.arg1_type = ARG_PTR_TO_STACK,
>> +	.arg2_type = ARG_CONST_STACK_SIZE,
>> +};
>
> A nit, please align such initializations vertically, for more
> readability:
>
> static const struct bpf_func_proto bpf_trace_printk_proto = {
> 	.func		= bpf_trace_printk,
> 	.gpl_only	= true,
> 	.ret_type	= RET_INTEGER,
> 	.arg1_type	= ARG_PTR_TO_STACK,
> 	.arg2_type	= ARG_CONST_STACK_SIZE,
> };

sure. will respin.
