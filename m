From: Christoph Lameter <cl@gentwo.org>
Subject: Re: big picture UDP/IP performance question re 2.6.18  -> 2.6.32
Date: Wed, 5 Oct 2011 09:26:24 -0500 (CDT)
Message-ID: <alpine.DEB.2.00.1110050915160.30467@router.home>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>  <alpine.DEB.2.00.1110041358500.12199@router.home> <1317820942.6766.26.camel@twins>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: starlight@binnacle.cx, Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>, Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317820942.6766.26.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 5 Oct 2011, Peter Zijlstra wrote:

> Clearly none of the tests being ran on a regular basis, by for instance
> the Intel regression team, covers your needs. Start by fixing that.

The most commonly run, the aged old tests contained in the AIM9 suite,
have consistently shown these regressions over long years and they have
been brought up repeatedly in numerous discussions. This is pervasive
thoughout the OS hotpaths. Just look at how the page fault latencies
change over time. Take a modern machine and then run successively older
kernel versions on it. You will see performance getting better and
latencies becoming smaller.

> Also, for latency, we've got ftrace and a latencytracer, provide traces
> that illustrate your fail.

We would need a backport of both to a kernel version that works with
reasonable latencies so that we can figure out what caused these
regressions for this particular case. Disabling network and kernel
features usually gives you better performance but there are a lot of
things in the hot paths these days that can not be disabled.
