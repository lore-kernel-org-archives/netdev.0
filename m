From: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
Subject: Re: eBPF verifier thoughts (Re: [PATCH v15 net-next 00/11] eBPF
 syscall, verifier, testsuite)
Date: Fri, 26 Sep 2014 15:07:16 -0700
Message-ID: <CALCETrWcmZVmRZARM_s9S-zZ4Xm_TcxRrzJWGwL0O9ySmVgr5A@mail.gmail.com>
References: <CALCETrVrHHxGo1RkPu+9LVnPo9XY9yYnJzg2ot0zOgoBspzbOQ@mail.gmail.com>
 <CAMEtUuyt9RASKZ4NeqK_OUYNN8QT6P20+kjcwywchur6QXSt0A@mail.gmail.com>
 <CALCETrXS5KBHm-3Fz031VFPpTHC_BDOLd_zNB6DjCidZa5-x2A@mail.gmail.com>
 <CAMEtUux-WFOGABTrWW=BGUstE=Zz6agXTGCGrRJtNXDfRmx-5A@mail.gmail.com>
 <CALCETrVLtJOYkHwsmwueZ7jsSgrNED564W+m4FmMZJZL-836mg@mail.gmail.com> <CAMEtUuxq7oNmDAHZ+1t4Vd-QhW6SV7eoM_juxXGEDJBF3Nfu6A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Hannes Frederic Sowa <hannes-tFNcAqjVMyqKXQKiL6tip0B+6BGkLq7r@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Pablo Neira Ayuso <pablo-Cap9r6Oaw4JrovVCs/uTlw@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAMEtUuxq7oNmDAHZ+1t4Vd-QhW6SV7eoM_juxXGEDJBF3Nfu6A-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 26, 2014 at 3:03 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
> On Fri, Sep 26, 2014 at 2:47 PM, Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org> wrote:
>>
>> Can't you just disallow the 1-byte write to the stack?
>
> of course not.
> That would be extremely limiting to users.
> Can you actually see yourself living with stack that only
> allows 8-byte writes/reads?
> The stack usage will increase a lot, since all char/short
> stack variables will become 8-byte...

How about requiring that sub-8-byte stack accesses only be to integer slots?

>
>> I'll try it in Python.  I bet I can get it to be shorter than the current code.
>
> Awesome challenge! :)
> I'll buy you a drink of your choice if you can achieve that.
> Also I'll send you our C programs that we use for
> testing to make sure, your python verifier can analyze them.
> If it passes, I'll be glad to rip mine out. Seriously.
> Deal?

Sure.

>
>> Yes, but does it work reliably?
>
> I'm not saying current verifier is perfect. It can get better.
> So far it was enough to let people code freely on top of it.



-- 
Andy Lutomirski
AMA Capital Management, LLC
