From: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Subject: Re: [PATCH v2 net-next 0/3] bpf: share helpers between tracing and
 networking
Date: Thu, 18 Jun 2015 10:10:26 +0200
Message-ID: <55827CF2.3000605@iogearbox.net>
References: <1434163154-5218-1-git-send-email-ast@plumgrid.com> <20150615.160130.583783771772303463.davem@davemloft.net> <557F97F3.6060400@plumgrid.com> <557FEA2C.5080408@iogearbox.net> <558058A0.7030201@plumgrid.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org, mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org,
	wangnan0-hv44wF8Li93QT0dZR+AlfA@public.gmane.org, lizefan-hv44wF8Li93QT0dZR+AlfA@public.gmane.org,
	daniel.wagner-98C5kh4wR6ohFhg+JK9F0w@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <558058A0.7030201-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 06/16/2015 07:10 PM, Alexei Starovoitov wrote:
...
> Ideally we would allow a blend of tracing and networking programs,
> then the best solution would be one or two stable tracepoints in
> networking stack where skb is visible and receiving/transmitting task
> is also visible, then skb->len and task->pid together would give nice
> foundation for accurate stats.

I think combining both seems interesting anyway, we need to find
a way to make this gluing of both worlds easy to use, though. It's
certainly interesting for stats/diagnostics, but one wouldn't be
able to use the current/future skb eBPF helpers from {cls,act}_bpf
in that context.
