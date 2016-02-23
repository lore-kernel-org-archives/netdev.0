From: Josh Poimboeuf <jpoimboe@redhat.com>
Subject: Re: [PATCH 00/33] Compile-time stack metadata validation
Date: Tue, 23 Feb 2016 09:07:55 -0600
Message-ID: <20160223150755.GC15858@treble.redhat.com>
References: <cover.1453405861.git.jpoimboe@redhat.com>
 <20160223081406.GA606@gmail.com>
 <20160223142717.GA3607@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Ingo Molnar <mingo@kernel.org>,
	Thomas Gleixner <tglx@linutronix.de>,
	Ingo Molnar <mingo@redhat.com>,
	"H. Peter Anvin" <hpa@zytor.com>, x86@kernel.org,
	linux-kernel@vger.kernel.org, live-patching@vger.kernel.org,
	Michal Marek <mmarek@suse.cz>,
	Peter Zijlstra <peterz@infradead.org>,
	Andy Lutomirski <luto@kernel.org>,
	Borislav Petkov <bp@alien8.de>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	Andi Kleen <andi@firstfloor.org>,
	Pedro Alves <palves@redhat.com>,
	Namhyung Kim <namhyung@gmail.com>,
	Bernd Petrovitsch <bernd@petrovitsch.priv.at>,
	Chris J Arges <chris.j.arges@canonical.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Jiri Slaby <jslaby@suse.cz>,
	David Vrabel <david.vrabel@citrix.com>,
	Borislav Petkov <bp@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	Boris Ostrovsky <boris.ostrovsky@oracle.com>,
	Jeremy Fitzhardinge <jeremy@goop.org>,
	Chris W
To: Arnaldo Carvalho de Melo <acme@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20160223142717.GA3607@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Feb 23, 2016 at 11:27:17AM -0300, Arnaldo Carvalho de Melo wrote:
> Em Tue, Feb 23, 2016 at 09:14:06AM +0100, Ingo Molnar escreveu:
> > The fact that 'stacktool' already checks about assembly details like __ex_table[] 
> > shows that my review feedback early iterations of this series, that the 
> > 'stacktool' name is too specific, was correct.
> > 
> > We really need to rename it before it gets upstream and the situation gets worse. 
> > __ex_table[] has obviously nothing to do with the 'stack layout' of binaries.
> > 
> > Another suitable name would be 'asmtool' or 'objtool'. For example the following 
> > would naturally express what it does:
> > 
> >   objtool check kernel/built-in.o
> > 
> > the name expresses that the tool checks object files, independently of the 
> > existing toolchain. Its primary purpose right now is the checking of stack layout 
> > details, but the tool is not limited to that at all.
> 
> Removing 'tool' from the tool name would be nice too :-) Making it
> easily googlable would be good too, lotsa people complain about 'perf'
> being too vague, see for a quick laugher:
> 
> http://www.brendangregg.com/perf.html
> 
> ``Searching for just "perf" finds sites on the police, petroleum, weed
> control, and a T-shirt. This is not an official perf page, for either
> perf_events or the T-shirt.''
> 
> The T-shirt: http://www.brendangregg.com/perf_events/omg-so-perf.jpg

Yeah, 'tool' in the name is kind of silly, but the above type of
situation is why I prefer 'objtool' over 'obj'.

Though I have to admit I like the idea of making a t-shirt for it ;-)

> Maybe we should ask Linus to come with some other nice, short,
> searchable, funny name like 'git'?
> 
> 'chob' as in 'check object'?

I think 'objtool' is searchable enough.  And I also like the fact that
its name at least gives you an idea of what it does (and eventually it
will do more than just "checking").

-- 
Josh
