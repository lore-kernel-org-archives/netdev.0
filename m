From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v3 linux-trace 4/8] samples: bpf: simple tracing example
 in C
Date: Mon, 9 Feb 2015 21:47:42 -0800
Message-ID: <CAMEtUuyCmO+N2SOTNXfOVnRA59TWsZczPCJBWsB+h0E45NxHPA@mail.gmail.com>
References: <1423539961-21792-1-git-send-email-ast@plumgrid.com>
 <1423539961-21792-5-git-send-email-ast@plumgrid.com> <20150209230836.7f913c60@grimm.local.home>
 <20150210001608.157a9190@grimm.local.home> <CAMEtUuzon5LfG7PS9YmuW+0GzYMKehz1Ddk+6tXogZOZYdpb3g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Masami Hiramatsu <masami.hiramatsu.pt-FCd8Q96Dh0JBDgjK7y7TUQ@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuzon5LfG7PS9YmuW+0GzYMKehz1Ddk+6tXogZOZYdpb3g-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 9, 2015 at 9:45 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> I thought we already stated that.
> Here is the quote from perf_event.h:
>          *      # The RAW record below is opaque data wrt the ABI
>          *      #
>          *      # That is, the ABI doesn't make any promises wrt to
>          *      # the stability of its content, it may vary depending
>          *      # on event, hardware, kernel version and phase of
>          *      # the moon.
>          *      #
>          *      # In other words, PERF_SAMPLE_RAW contents are not an ABI.
>
> and this example is reading PERF_SAMPLE_RAW events and
> uses locally defined structs to print them for simplicity.

to underline my point once more:
addition of bpf doesn't change at all what PERF_SAMPLE_RAW already
delivers to user space.
so no new ABIs anywhere.
