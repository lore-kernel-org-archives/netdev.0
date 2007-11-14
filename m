From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [BUG] New Kernel Bugs
Date: Wed, 14 Nov 2007 21:54:30 +0100
Message-ID: <20071114205427.GC20606@elte.hu>
References: <20071113134029.GA30978@elte.hu> <20071113085514.3414aa52.rdunlap@xenotime.net> <20071114140847.GA11489@elte.hu> <20071114.115601.00715073.davem@davemloft.net> <1195070954.8364.41.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, rdunlap@xenotime.net,
	akpm@linux-foundation.org, protasnb@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	alsa-devel@alsa-project.org, linux-ide@vger.kernel.org,
	linux-pcmcia@lists.infradead.org,
	linux-input@atrey.karlin.mff.cuni.cz,
	bugme-daemon@bugzilla.kernel.org
To: James Bottomley <James.Bottomley@HansenPartnership.com>
Return-path: <owner-linux-input@atrey.karlin.mff.cuni.cz>
Content-Disposition: inline
In-Reply-To: <1195070954.8364.41.camel@localhost.localdomain>
Sender: owner-linux-input@atrey.karlin.mff.cuni.cz
List-Help: <mailto:majordomo@atrey.karlin.mff.cuni.cz?body=help>
List-Owner: <mailto:owner-linux-input@atrey.karlin.mff.cuni.cz>
List-Post: <mailto:linux-input@atrey.karlin.mff.cuni.cz>
List-Unsubscribe: <mailto:linux-input-request@atrey.karlin.mff.cuni.cz?body=unsubscribe>
List-Id: netdev.vger.kernel.org


* James Bottomley <James.Bottomley@HansenPartnership.com> wrote:

> On Wed, 2007-11-14 at 11:56 -0800, David Miller wrote:
> > From: Ingo Molnar <mingo@elte.hu>
> > Date: Wed, 14 Nov 2007 15:08:47 +0100
> > 
> > > In fact this thread is the very example: David points out that on netdev 
> > > some of those bugs were already discussed and resolved. Had it been all 
> > > on lkml we'd all be aware of it.
> > 
> > That's a rediculious argument.
> > 
> > One other reason these bugs are resolved, is that the networking 
> > developers only need to subscribe to netdev and not have to listen 
> > to all the noise on lkml.
> > 
> > People who want to manage bugs know what list to look on and contact 
> > about problems.
> > 
> > Dumping even more crap on lkml is not the answer.
> 
> I agree totally with David, and this goes for SCSI too.  If it's not 
> reported on linux-scsi, there's a significant chance of us missing the 
> bug report.  The fact that some people notice bugs go past on LKML and 
> forward them to linux-scsi is a happy accident and not necessarily 
> something to rely on.
> 
> LKML has 10-20x the traffic of linux-scsi and a much smaller signal to 
> noise ratio.  Having a specialist list where all the experts in the 
> field hangs out actually enhances our ability to fix bugs.

you are actually proving my point. People have to scan lkml for SCSI 
regressions _anyway_, because otherwise _you_ would miss them. In the 
case a user is fortunate enough to realize that a regression is SCSI 
related, and he is lucky enough to pre-select the SCSI mailing list in 
the first go, he might get a fix from you. That already reduces the 
number of useful bugreports by about an order of magnitude.

	Ingo
