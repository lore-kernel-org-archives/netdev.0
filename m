From: Arthur Kepner <akepner@sgi.com>
Subject: Re: NAPI, e100, and system performance problem
Date: Fri, 22 Apr 2005 11:37:17 -0700 (PDT)
Message-ID: <Pine.LNX.4.61.0504221131350.15052@linux.site>
References: <C925F8B43D79CC49ACD0601FB68FF50C03A633C7@orsmsx408>
 <Pine.LNX.4.61.0504180943290.15052@linux.site> <1113855967.7436.39.camel@localhost.localdomain>
 <20050419055535.GA12211@sgi.com> <m1hdhzyrdz.fsf@muc.de>
 <1114173195.7679.30.camel@localhost.localdomain> <20050422172108.GA10598@muc.de>
 <1114193902.7978.39.camel@localhost.localdomain> <20050422183004.GC10598@muc.de>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: jamal <hadi@cyberus.ca>, Greg Banks <gnb@sgi.com>,
        "Brandeburg, Jesse" <jesse.brandeburg@intel.com>, netdev@oss.sgi.com,
        davem@redhat.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Andi Kleen <ak@muc.de>
In-Reply-To: <20050422183004.GC10598@muc.de>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Fri, 22 Apr 2005, Andi Kleen wrote:

> ....
> Also I doubt the workload Jesse and Greg/Arthur/SGI saw also had issues
> with CPU power (can you guys confirm?)
> 

The problem that we've had is that flushing PIOs can take a long 
time. So the CPU can spend more time spinning, waiting for the PIOs 
to flush, than doing useful work. 

I'm going to try to get some new (2.6.12-rc2) data this weekend.

--
Arthur
