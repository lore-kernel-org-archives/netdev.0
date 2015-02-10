From: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 4/8] samples: bpf: simple tracing example
 in C
Date: Tue, 10 Feb 2015 00:16:08 -0500
Message-ID: <20150210001608.157a9190@grimm.local.home>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
	<1423539961-21792-5-git-send-email-ast@plumgrid.com>
	<20150209230836.7f913c60@grimm.local.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20150209230836.7f913c60-2kNGR76GQU9OHLTnHDQRgA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, 9 Feb 2015 23:08:36 -0500
Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org> wrote:
 
> I don't want to get stuck with pinned kernel data structures again. We
> had 4 blank bytes of data for every event, because latency top hard
> coded the field. Luckily, the 64 bit / 32 bit interface caused latency
> top to have to use the event_parse code to work, and we were able to
> remove that field after it was converted.

I'm wondering if we should label eBPF programs as "modules". That is,
they have no guarantee of working from one kernel to the next. They
execute in the kernel, thus they are very similar to modules.

If we can get Linus to say that eBPF programs are not user space, and
that they are treated the same as modules (no internal ABI), then I
think we can be a bit more free at what we allow.

-- Steve
