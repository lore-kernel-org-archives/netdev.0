From: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH net-next 1/2] bpf: enable non-root eBPF programs
Date: Thu, 8 Oct 2015 08:21:55 +0200
Message-ID: <20151008062155.GA18452@gmail.com>
References: <1444078101-29060-1-git-send-email-ast@plumgrid.com>
 <1444078101-29060-2-git-send-email-ast@plumgrid.com>
 <5612F639.2050305@iogearbox.net>
 <56131B1F.80002@plumgrid.com>
 <5613C261.4080302@iogearbox.net>
 <56158CAF.9030209@plumgrid.com>
 <561597A6.4000203@iogearbox.net>
 <CAGXu5jLM5Wp_PjdcEcxUo-VoEmsSycF236MZaJd2wvLjbQx+eQ@mail.gmail.com>
 <5615AF92.50402@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <5615AF92.50402-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


* Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:

> As far as sysctl we can look at two with similar purpose:
> sysctl_perf_event_paranoid and modules_disabled.
> First one is indeed multi level, but not because of the fear of bugs,
> but because of real security implications.

It serves both purposes flexibly, and note that most people and distros will use 
the default value.

> [...] Like raw events on hyperthreaded cpu or uncore events can extract data 
> from other user processes. So it controls these extra privileges.

It also controls the generally increased risk caused by a larger attack surface, 
which some users may not want to carry and which they can thus shrink.

With a static keys approach there would be no runtime overhead worth speaking of, 
so I see no reason why unprivileged eBPF couldn't have a sysctl too - with the 
default value set to permissive.

Thanks,

	Ingo
