From: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v9 tip 0/9] tracing: attach eBPF programs to kprobes
Date: Mon, 23 Mar 2015 08:36:44 +0100
Message-ID: <20150323073643.GD25184@gmail.com>
References: <1426894210-27441-1-git-send-email-ast@plumgrid.com>
 <20150321000812.606ef8cb@grimm.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
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
Content-Disposition: inline
In-Reply-To: <20150321000812.606ef8cb-2kNGR76GQU9OHLTnHDQRgA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


* Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:

> On Fri, 20 Mar 2015 16:30:01 -0700
> Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> 
> > Hi Ingo,
> > 
> > I think it's good to go.
> > Patch 1 is already in net-next. Patch 3 depends on it.
> > I'm assuming it's not going to be a problem during merge window.
> > Patch 3 will have a minor conflict in uapi/linux/bpf.h in linux-next,
> > since net-next has added new lines to the bpf_prog_type and bpf_func_id enums.
> > I'm assuming it's not a problem either.
> > 
> > V8->V9:
> > - fixed comment style and allowed ispunct after %p
> > - added Steven's Reviewed-by. Thanks Steven!
> 
> Hi Ingo,
> 
> I'm fine with this series, so don't let me hold it up from going into
> your tree.

Ok, thanks!

Looks like a very powerful instrumentation interface to me.

Thanks,

	Ingo
