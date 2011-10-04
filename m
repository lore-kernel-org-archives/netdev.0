From: Joe Perches <joe@perches.com>
Subject: Re: big picture UDP/IP performance question re 2.6.18  -> 2.6.32
Date: Tue, 04 Oct 2011 12:38:38 -0700
Message-ID: <1317757118.3580.24.camel@Joe-Laptop>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
	 <alpine.DEB.2.00.1110041358500.12199@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: starlight@binnacle.cx, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Stephen Hemminger <stephen.hemminger@vyatta.com>
To: Christoph Lameter <cl@gentwo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1110041358500.12199@router.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-10-04 at 14:16 -0500, Christoph Lameter wrote:
> On Mon, 3 Oct 2011, starlight@binnacle.cx wrote:
> > I've come to the conclusion that Eric is right
> > and the primary issue is an increase in the
> > cost of scheduler context switches.  Have
> > been watching this number and it has held
> > pretty close to 200k/sec under all scenarios
> > and kernel versions, so it has to be
> > a longer code-path, bigger cache pressure
> > or both in the scheduler.  Sadly this makes
> > newer kernels a no-go for us.
> We had similar experiences. Basically latency constantly gets screwed up
> by the new fancy features being added to the scheduler and network
> subsystem (most notorious is the new "fair" scheduler, 2.6.23 made a big
> step down).

Idly curious, have you compared bfs performance?
http://ck.kolivas.org/patches/bfs/bfs-faq.txt
