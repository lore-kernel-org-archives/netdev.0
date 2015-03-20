From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v8 tip 3/9] tracing: attach BPF programs to kprobes
Date: Fri, 20 Mar 2015 14:38:40 -0700
Message-ID: <550C9360.7060207@plumgrid.com>
References: <1426816787-5001-1-git-send-email-ast@plumgrid.com>	<1426816787-5001-4-git-send-email-ast@plumgrid.com> <20150320170907.388d8c33@gandalf.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150320170907.388d8c33-f9ZlEuEWxVcJvu8Pb33WZ0EMvNT87kid@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 3/20/15 2:09 PM, Steven Rostedt wrote:
>
>> +/**
>> + * trace_call_bpf - invoke BPF program
>> + * @prog - BPF program
>> + * @ctx - opaque context pointer
>> + *
>> + * kprobe handlers execute BPF programs via this helper.
>> + * Can be used from static tracepoints in the future.
>
> Should also state what the expected return values are. What does a
> return of "1" mean?

In earlier versions of this set I had detailed description of return
values from bpf program, somehow it got lost after all the revisions.
Will re-add.


> You are no longer in the net/ world. The rest of the Linux coding style
> is:
>
> 	/*
> 	 * multi line comments
> 	 */
>
> Only DaveM gets away with that format ;-)

:)
since bpf was born in the net/ world all comments are in that style.
When it moved into kernel/bpf/ we've decided to keep net/ style in there
as well, but for this file I don't mind using !net style ;)

> Reviewed-by: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>

Thanks a lot. Will respin.
