From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [netfilter-core] [2.6 patch] net/ipv4/netfilter/: misc
	possible cleanups
Date: Thu, 16 Dec 2004 12:40:48 +1100
Message-ID: <1103161248.2200.7.camel@localhost.localdomain>
References: <20041215011931.GD12937@stusta.de>
	<20041215090322.GA2862@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, Netfilter Core Team <coreteam@netfilter.org>,
	Netfilter development mailing list <netfilter-devel@lists.netfilter.org>,
	lkml - Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Adrian Bunk <bunk@stusta.de>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Harald Welte <laforge@netfilter.org>
In-Reply-To: <20041215090322.GA2862@sunbeam.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Wed, 2004-12-15 at 10:03 +0100, Harald Welte wrote:
> On Wed, Dec 15, 2004 at 02:19:31AM +0100, Adrian Bunk wrote:
> > The patch below contains the following possible cleanups:
...
> As you might be aware, netfilter/iptables has an enormously large
> codebase (I'd say even larger than what is in the tree) in the so-called
> patch-o-matic subsystem.  The abovementioned exports facilitate those
> modulse, and A certain amount of those new modules (especially the ones
> requiring the functions above) are scheduled for mainline inclusion over
> the next couple of months.

True, but some of these cleanups are genuine.  Deleting code also
increases the coverage of the testsuite: I've put this in my patch set
and will merge them in pieces.  At the rate I work, those that are
needed in the next few months won't be deleted.  If patches are not due
to be merged in that timeframe, it'd be nice if they contained the
exports etc. that they need rather than relying on long-term unused
features of the tree.

Cheers,
Rusty.
-- 
A bad analogy is like a leaky screwdriver -- Richard Braakman
