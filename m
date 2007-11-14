From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 21:48:40 +0100
Message-ID: <20071114204840.GB20606@elte.hu>
References: <20071113134029.GA30978@elte.hu> <20071113085514.3414aa52.rdunlap@xenotime.net> <20071114140847.GA11489@elte.hu> <20071114.115601.00715073.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: rdunlap@xenotime.net, akpm@linux-foundation.org, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
Content-Disposition: inline
In-Reply-To: <20071114.115601.00715073.davem@davemloft.net>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org


* David Miller <davem@davemloft.net> wrote:

> From: Ingo Molnar <mingo@elte.hu>
> Date: Wed, 14 Nov 2007 15:08:47 +0100
> 
> > In fact this thread is the very example: David points out that on netdev 
> > some of those bugs were already discussed and resolved. Had it been all 
> > on lkml we'd all be aware of it.
> 
> That's a rediculious argument.
> 
> One other reason these bugs are resolved, is that the networking 
> developers only need to subscribe to netdev and not have to listen to 
> all the noise on lkml.

what noise? If someone really wants networking discussions only, use 
this procmail rule:

  :0 HBc
          * .*net: *
          sched-patches

to separate it into an extra folder and use "net: " as an agreed upon 
Subject line if you really want to narrow things down. (But there would 
still be all the other mail just in case the developer has to look at 
the wider picture. There would be no "I'm only subscribed to netdev" 
excuse. )

but there should still be one central repository for all kernel 
discussions - just like there is one central repository for all kernel 
code.

> People who want to manage bugs know what list to look on and contact 
> about problems.

i think that's the problem. Developers (and here i dont mean you) who
want to do "development only", without being exposed to the global state
of the kernel and without being exposed to bugs. I think that's the
basic mindset difference. That is one of the factor that is causing
assymetric allocation of developers and the increasing detachment from
reality.

> Dumping even more crap on lkml is not the answer.

that "crap" that i'd like to see dumped upon lkml would be netdev 
traffic mainly - most of the other kernel development lists (and i'm 
subscribed to many of them) are low-traffic. netdev is the main reason 
why we cannot do a "one common discussion forum" approach.

	Ingo
