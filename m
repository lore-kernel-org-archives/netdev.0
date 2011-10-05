From: Peter Zijlstra <a.p.zijlstra@chello.nl>
Subject: Re: big picture UDP/IP performance question re 2.6.18  -> 2.6.32
Date: Wed, 05 Oct 2011 15:22:22 +0200
Message-ID: <1317820942.6766.26.camel@twins>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
	 <alpine.DEB.2.00.1110041358500.12199@router.home>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: starlight@binnacle.cx, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>, Ingo Molnar <mingo@elte.hu>
To: Christoph Lameter <cl@gentwo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <alpine.DEB.2.00.1110041358500.12199@router.home>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2011-10-04 at 14:16 -0500, Christoph Lameter wrote:
> 
> We had similar experiences. Basically latency constantly gets screwed up
> by the new fancy features being added to the scheduler and network
> subsystem (most notorious is the new "fair" scheduler, 2.6.23 made a big
> step down). The kernel has a fairly constant regression in terms of
> latency release after release. Only the new and more efficient processors
> periodically provide some compensation (and some isolated patches to
> actually improve things get in but these are usually watered down one or
> two releases after those improvements have been made). 

I suppose all this testing and feedback we receive from you really helps
us keep the performance levels you want.. Oh wait, that's 0.

Clearly none of the tests being ran on a regular basis, by for instance
the Intel regression team, covers your needs. Start by fixing that.

Also, for latency, we've got ftrace and a latencytracer, provide traces
that illustrate your fail.
