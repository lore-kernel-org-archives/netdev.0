From: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH RFC v7 net-next 00/28] BPF syscall
Date: Wed, 27 Aug 2014 21:35:32 +0200
Message-ID: <53FE3304.9040305@redhat.com>
References: <1409106582-10095-1-git-send-email-ast@plumgrid.com> <CALCETrX2MzNxQ1ogt+Qx8iPjUe+z0gN6ZLwu9nAcZzTN+D+iYw@mail.gmail.com> <CAMEtUuwYqJVUuZxPBKy57NonWF+X_5vkNx4uSEx_d=-xBka1Kg@mail.gmail.com> <CALCETrWs9GRufGKxAoV628bh1f3HObkxNQuW3tYRt2rFwNAbxA@mail.gmail.com> <CAMEtUuw1n1HzAeyKFj9=nGq7RKZq7TADS-6M_BkHbTsWJ_Gm-Q@mail.gmail.com> <CALCETrXAfZJTsF2nPFw55rHkfbNXKQuF8Frnq3e1wHEoGxLM4w@mail.gmail.com> <20140827121801.3bfd916e@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20140827121801.3bfd916e@urahara>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 08/27/2014 09:18 PM, Stephen Hemminger wrote:
> Something in man page format similar to FreeBSD man page:
>   http://www.freebsd.org/cgi/man.cgi?bpf(4)
>
> would be more readable and reviewable.

I think at some point, we could perhaps do a section 7 page
with a general overview of the engine and where it can be
applied, and let the syscall page partially refer to it so
that it doesn't get too long. So far, we tried to squeeze
everything into Documentation/networking/filter.txt, and that
itself is quite long already.
