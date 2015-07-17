From: Phil Sutter <phil@nwl.cc>
Subject: Re: 4.1 regression in resizable hashtable tests
Date: Fri, 17 Jul 2015 12:29:45 +0200
Message-ID: <20150717102945.GB21732@orbit.nwl.cc>
References: <alpine.LRH.2.11.1507011259180.4092@math.ut.ee>
 <20150702123130.GA20843@pox.localdomain>
 <alpine.LRH.2.11.1507022208200.28236@math.ut.ee>
 <20150717080456.GA13814@pox.localdomain>
 <20150717102636.GA21732@orbit.nwl.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Thomas Graf <tgraf@suug.ch>, Meelis Roos <mroos@linux.ee>,
	sparclinux@vger.kernel.org,
	Linux Kernel list <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20150717102636.GA21732@orbit.nwl.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 17, 2015 at 12:26:36PM +0200, Phil Sutter wrote:
> On Fri, Jul 17, 2015 at 10:04:56AM +0200, Thomas Graf wrote:
> > On 07/02/15 at 10:09pm, Meelis Roos wrote:
> > > [   33.425061] Running rhashtable test nelem=8, max_size=65536, shrinking=0
> > > [   33.425154] Test 00:
> > > [   33.534470]   Adding 50000 keys
> > > [   34.743553] Info: encountered resize
> > > [   34.743698] Info: encountered resize
> > > [   34.743838] Info: encountered resize
> > > [   34.744057] Info: encountered resize
> > > [   34.744430] Info: encountered resize
> > > [   34.745139] Info: encountered resize
> > > [   34.746441] Info: encountered resize
> > > [   34.749055] Info: encountered resize
> > > [   34.754469] Info: encountered resize
> > > [   34.764836] Info: encountered resize
> > > [   34.785696] Info: encountered resize
> > > [   34.827448] Info: encountered resize
> > > [   34.896936]   Traversal complete: counted=49993, nelems=50000, entries=50000, table-jumps=12
> > > [   34.897056] Test failed: Total count mismatch ^^^
> > 
> > I do see count mismatches as well due to the design of the walker
> > which restarts and thus sees certain entries multiple times.
> > 
> > Do you have this commit as well?
> > 
> > Author: Phil Sutter <phil@nwl.cc>
> > Date:   Mon Jul 6 15:51:20 2015 +0200
> > 
> >     rhashtable: fix for resize events during table walk
> 
> Thomas, this should be resolved already. Meelis replied[1] to my patch,
> stating it fixes that problem for him. Though he's still waiting for
> your proposed patch to add a schedule() call so the kernel won't
> complain on his slow UltraSparc. :)

Ah, nevermind. You sent it already with him in Cc.
