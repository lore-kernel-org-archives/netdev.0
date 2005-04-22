From: Andi Kleen <ak@muc.de>
Subject: Re: NAPI, e100, and system performance problem
Date: 22 Apr 2005 20:30:04 +0200
Message-ID: <20050422183004.GC10598@muc.de>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408> <Pine.LNX.4.61.0504180943290.15052@linux.site> <1113855967.7436.39.camel@localhost.localdomain> <20050419055535.GA12211@sgi.com> <m1hdhzyrdz.fsf@muc.de> <1114173195.7679.30.camel@localhost.localdomain> <20050422172108.GA10598@muc.de> <1114193902.7978.39.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg Banks <gnb@sgi.com>, Arthur Kepner <akepner@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
Date: Fri, 22 Apr 2005 20:30:04 +0200
To: jamal <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1114193902.7978.39.camel@localhost.localdomain>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Apr 22, 2005 at 02:18:22PM -0400, jamal wrote:
> On Fri, 2005-22-04 at 19:21 +0200, Andi Kleen wrote:
> > On Fri, Apr 22, 2005 at 08:33:15AM -0400, jamal wrote:
> [..]
> > > They should not run slower - but they may consume more CPU.
> > 
> > They actually run slower.
> > 
> 
> Why do they run slower? There could be 1000 other variables involved?
> What is it that makes you so sure it is NAPI?
> I know you are capable of proving it is NAPI - please do so.

We tested back then by downgrading to an older non NAPI tg3 driver
and it made the problem go away :) The broadcom bcm57xx driver which
did not support NAPI at this time was also much faster.

> > Now before David complains this was with old 2.6 kernels and I dont have
> > time right now to rerun the benchmarks, but at least I dont think
> > there was ever any patch addressing these issues.
> > 
> 
> It would be helpful if you use new kernels of course - that reduces the
> number of variables to look at. 

It was customers who use certified SLES kernels.

> There is only one complaint I have ever heard about NAPI and it is about
> low rates: It consumes more CPU at very low rates. Very low rates

It was not only more CPU usage, but actually slower network performance
on systems with plenty of CPU power.

Also I doubt the workload Jesse and Greg/Arthur/SGI saw also had issues
with CPU power (can you guys confirm?)

> You are the first person i have heard that says NAPI would be slower
> in terms of throughput or latency at low rates. My experiences is there
> is no difference between the two at low input rate.  It would be
> interesting to see the data.

Well, did you ever test a non routing workload?

-Andi
