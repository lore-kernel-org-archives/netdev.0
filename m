From: Lee Revell <rlrevell@joe-job.com>
Subject: Re: RCU latency regression in 2.6.16-rc1
Date: Wed, 25 Jan 2006 18:13:57 -0500
Message-ID: <1138230838.3087.54.camel@mindpipe>
References: <20060124080157.GA25855@elte.hu>
	 <1138090078.2771.88.camel@mindpipe> <20060124081301.GC25855@elte.hu>
	 <1138090527.2771.91.camel@mindpipe> <20060124091730.GA31204@us.ibm.com>
	 <20060124092330.GA7060@elte.hu> <1138095856.2771.103.camel@mindpipe>
	 <20060124162846.GA7139@in.ibm.com> <20060124213802.GC7139@in.ibm.com>
	 <1138224506.3087.22.camel@mindpipe>  <20060125225639.GA1382@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: dipankar@in.ibm.com, "Paul E. McKenney" <paulmck@us.ibm.com>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	Linus Torvalds <torvalds@osdl.org>,
	NetDev <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932209AbWAYXOA@vger.kernel.org>
To: Ingo Molnar <mingo@elte.hu>
In-Reply-To: <20060125225639.GA1382@elte.hu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-01-25 at 23:56 +0100, Ingo Molnar wrote:
> 
> yes, that would be a nice test. (I'm busy now with mutex stuff to be 
> able to do a working softirq-preemption patch, but i sent you my
> current patches off-list - if you want to give it a shot. Be warned
> though, there will likely be quite some merging work to do, so it's
> definitely not for the faint hearted.)
> 

OK, I probably won't have time to test it this week either.

In the meantime can anyone explain briefly why such a heavy fix is
needed?  It seems like it would be simpler to make the route cache
flushing operate in batches of 100 routes, rather than invalidating the
whole thing in one shot.  This does seem to be the only softirq that
regularly runs for much more than 1ms.

Would this require major surgery on the networking subsystem?

Lee
