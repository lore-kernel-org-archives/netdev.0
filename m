From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH v11 net-next 00/12] eBPF syscall, verifier, testsuite
Date: Thu, 11 Sep 2014 13:35:31 -0700
Message-ID: <CAMEtUuyTfRwZi1-yOyrAOkubWLDLC6YZXUq8OFpqXpHPjKRYhw@mail.gmail.com>
References: <1410325808-3657-1-git-send-email-ast@plumgrid.com>
	<CALCETrVBb_uQZpodv67XSTGVU40y6+9Ktw=3zAJgGV2mNJ=_0A@mail.gmail.com>
	<CAMEtUuyY0L2=tz5mSvQqR_=_oN18nA6V9fdbR8OiYTPbQth8AQ@mail.gmail.com>
	<5411FDE1.3060302@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <5411FDE1.3060302-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 11, 2014 at 12:54 PM, Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:
> On 09/10/2014 10:21 PM, Alexei Starovoitov wrote:
> ...
>>>>
>>>>                char bpf_log_buf[LOG_BUF_SIZE];
>>>
>>>
>>> What happens if the size isn't LOG_BUF_SIZE?
>>
>>
>> would do you mean?
>> LOG_BUF_SIZE is just a user defined macro.
>> Can be anything.
>
> I believe, Andy means, what would happen if log_level > 0 but
> the log_size is not big enough so that the human-readable error
> text string from the verifier will fit into it? I presume that
> will be truncated then ... hm.

Correct. It will be truncated and ENOSPC returned from syscall.
Just noticed that I didn't mention that in the manpage... will do.
