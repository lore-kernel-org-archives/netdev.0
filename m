From: Arnaldo Carvalho de Melo <acme-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Tue, 23 Feb 2016 11:27:17 -0300
Message-ID: <20160223142717.GA3607@kernel.org>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <20160223081406.GA606@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Josh Poimboeuf <jpoimboe-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Thomas Gleixner <tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org>,
	Ingo Molnar <mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>, x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, live-patching-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Michal Marek <mmarek-AlSwsSmVLrQ@public.gmane.org>,
	Peter Zijlstra <peterz-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	Andy Lutomirski <luto-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Borislav Petkov <bp-Gina5bIWoIWzQB+pC5nmwQ@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andi Kleen <andi-Vw/NltI1exuRpAAqCnN02g@public.gmane.org>,
	Pedro Alves <palves-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Namhyung Kim <namhyung-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Bernd Petrovitsch <bernd-JY8rjfDgnXcb9sJ47jD7nuTv7YV0F9Eg@public.gmane.org>,
	Chris J Arges <chris.j.arges-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Jiri Slaby <jslaby-AlSwsSmVLrQ@public.gmane.org>,
	David Vrabel <david.vrabel-Sxgqhf6Nn4DQT0dZR+AlfA@public.gmane.org>,
	Borislav Petkov <bp-l3A5Bk7waGM@public.gmane.org>,
	Konrad Rzeszutek Wilk <konrad.wilk-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Boris Ostrovsky <boris.ostrovsky-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>,
	Jeremy Fitzhardinge <jeremy-TSDbQ3PG+2Y@public.gmane.org>,
	C
To: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20160223081406.GA606-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-watchdog-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Em Tue, Feb 23, 2016 at 09:14:06AM +0100, Ingo Molnar escreveu:
> The fact that 'stacktool' already checks about assembly details like __ex_table[] 
> shows that my review feedback early iterations of this series, that the 
> 'stacktool' name is too specific, was correct.
> 
> We really need to rename it before it gets upstream and the situation gets worse. 
> __ex_table[] has obviously nothing to do with the 'stack layout' of binaries.
> 
> Another suitable name would be 'asmtool' or 'objtool'. For example the following 
> would naturally express what it does:
> 
>   objtool check kernel/built-in.o
> 
> the name expresses that the tool checks object files, independently of the 
> existing toolchain. Its primary purpose right now is the checking of stack layout 
> details, but the tool is not limited to that at all.

Removing 'tool' from the tool name would be nice too :-) Making it
easily googlable would be good too, lotsa people complain about 'perf'
being too vague, see for a quick laugher:

http://www.brendangregg.com/perf.html

``Searching for just "perf" finds sites on the police, petroleum, weed
control, and a T-shirt. This is not an official perf page, for either
perf_events or the T-shirt.''

The T-shirt: http://www.brendangregg.com/perf_events/omg-so-perf.jpg

Maybe we should ask Linus to come with some other nice, short,
searchable, funny name like 'git'?

'chob' as in 'check object'?

- Arnaldo
--
To unsubscribe from this list: send the line "unsubscribe linux-watchdog" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
