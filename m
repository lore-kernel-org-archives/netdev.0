From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH, RFC] RCU : OOM avoidance and lower latency
Date: Fri, 6 Jan 2006 23:18:34 +0100
Message-ID: <200601062318.35464.ak@suse.de>
References: <20060105235845.967478000@sorel.sous-sol.org> <200601061358.42344.ak@suse.de> <1136575600.17979.58.camel@mindpipe>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	Linus Torvalds <torvalds@osdl.org>,
	linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>,
	Manfred Spraul <manfred@colorfullife.com>,
	netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1750844AbWAFWd7@vger.kernel.org>
To: Lee Revell <rlrevell@joe-job.com>
In-Reply-To: <1136575600.17979.58.camel@mindpipe>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 06 January 2006 20:26, Lee Revell wrote:
> On Fri, 2006-01-06 at 13:58 +0100, Andi Kleen wrote:
> > Another CPU might be stuck in a long 
> > running interrupt
> 
> Shouldn't a long running interrupt be considered a bug?

In normal operation yes, but there can be always exceptional
circumstances where it's unavoidable (e.g. during error handling) 
and in the name of defensive programming the rest of the system ought 
to tolerate it.

-Andi
