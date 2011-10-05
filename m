From: starlight@binnacle.cx
Subject: Re: big picture UDP/IP performance question re 2.6.18
  -> 2.6.32
Date: Wed, 05 Oct 2011 11:12:15 -0400
Message-ID: <6.2.5.6.2.20111005110324.03a9df10@binnacle.cx>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
 <alpine.DEB.2.00.1110041358500.12199@router.home>
 <1317820942.6766.26.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Willy Tarreau <w@1wt.eu>, Ingo Molnar <mingo@elte.hu>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Christoph Lameter <cl@gentwo.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1317820942.6766.26.camel@twins>
References: <6.2.5.6.2.20111003112108.03a83a28@binnacle.cx>
 <alpine.DEB.2.00.1110041358500.12199@router.home>
 <1317820942.6766.26.camel@twins>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

At 03:22 PM 10/5/2011 +0200, Peter Zijlstra wrote:
>On Tue, 2011-10-04 at 14:16 -0500, Christoph Lameter wrote:
>I suppose all this testing and feedback we receive
>from you really helps us keep the performance
>levels you want.. Oh wait, that's 0.

Well I have to admit that I've looked into the
future (i.e. tested kernel.org releases) only on
occasion.  To the extent that performance wasn't
looking great I harbored an apparently over
optimistic hope that things would get tuned/fixed
in the process somewhere.  In particular I was
thinking that RH might do something impressive
with RHEL 6 where Novell failed with SLES 11.
However, if anything the downstream is fiddling
less and less with the kernel as it becomes ever
more complex.

>Clearly none of the tests being ran on a regular
>basis, by for instance the Intel regression team,
>covers your needs. Start by fixing that.

I could create a test case.  It's quite a lot more
than trivial, but not ridiculous either.  That UDP
is broken on everything past 2.6.27 may goad me
into the effort.  Have had a fairly excellent
experience WRT the hugepage kernel corruption bugs
I reported 18 months or so ago.  Not only did the
kernel developers fix them, the fixes made it
downstream into RHEL fairly quickly.  So that does
encourage me.
