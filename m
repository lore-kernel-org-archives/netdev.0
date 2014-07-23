From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH RFC v2 net-next 02/16] bpf: update MAINTAINERS entry
Date: Wed, 23 Jul 2014 10:48:55 -0700
Message-ID: <CAMEtUuzcMcYnRryykqb9LQWjnVmYi3ErMtGQ+9nyY5uS+OpwpQ@mail.gmail.com>
References: <1405657206-12060-1-git-send-email-ast@plumgrid.com>
	<1405657206-12060-3-git-send-email-ast@plumgrid.com>
	<CAGXu5j+mGDEPx5rCdVXzAdxR9SwQQ4ERM-Brxt4TmmncdPjzzg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Arnaldo Carvalho de Melo <acme-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Jiri Olsa <jolsa-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	LKML <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAGXu5j+mGDEPx5rCdVXzAdxR9SwQQ4ERM-Brxt4TmmncdPjzzg-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Wed, Jul 23, 2014 at 10:37 AM, Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org> wrote:
> On Thu, Jul 17, 2014 at 9:19 PM, Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org> wrote:
>> Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
>> ---
>>  MAINTAINERS |    7 +++++++
>>  1 file changed, 7 insertions(+)
>>
>> diff --git a/MAINTAINERS b/MAINTAINERS
>> index ae8cd00215b2..32e24ff46da3 100644
>> --- a/MAINTAINERS
>> +++ b/MAINTAINERS
>> @@ -1912,6 +1912,13 @@ S:       Supported
>>  F:     drivers/net/bonding/
>>  F:     include/uapi/linux/if_bonding.h
>>
>> +BPF (Safe dynamic programs and tools)
>
> bikeshed: I feel like this shouldn't be an acronym. Maybe instead:
>
> BERKELEY PACKET FILTER (BPF: Safe dynamic programs and tools)

pile on :)

I think eBPF is no longer acronym. 'e' stands for 'extended',
but BPF is no longer 'packet filter' only and definitely not 'berkeley'.
So I'd rather keep BPF as a magic abbreviation without spelling it out,
since full name is historic and no longer meaningful.
I've considered coming up with brand new abbreviation and full name
for this instruction set, but none looked good and all lose in comparison
to 'eBPF' name, which is concise and carries enough historical
references to explain the idea behind new ISA.
