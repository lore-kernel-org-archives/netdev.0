From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: PROBLEM: Silent data corruption when using sendfile()
Date: Sat, 14 Jul 2012 12:33:24 +0200
Message-ID: <1342262004.3265.9279.camel@edumazet-glaptop>
References: <20120713171835.GA26052@vault.local>
	 <CAJd=RBAntSubDBbJ292SzeoN4hTwBQ_Q23jt+Y6i-+vfrQ5EHQ@mail.gmail.com>
	 <1342254042.3265.9017.camel@edumazet-glaptop>
	 <20120714083136.GO16256@1wt.eu>  <20120714101321.GA26329@vault.local>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Willy Tarreau <w@1wt.eu>, Hillf Danton <dhillf@gmail.com>,
	linux-kernel@vger.kernel.org, Linux-Netdev <netdev@vger.kernel.org>
To: Johannes Truschnigg <johannes@truschnigg.info>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120714101321.GA26329@vault.local>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2012-07-14 at 12:13 +0200, Johannes Truschnigg wrote:
> On Sat, Jul 14, 2012 at 10:31:36AM +0200, Willy Tarreau wrote:
> > > Please Johannes could you try latest kernel tree ?
> > 
> > It would be useful, especially given the amount of changes you performed
> > in this area in latest version, it could be very possible that this new
> > bug got fixed as a side effect !
> 
> I upgraded to 3.4.4 (identical config as the 3.4.0 build I've been running)
> and what can I say - the problem really seems to have disappeared. I performed
> about 3700 iterations of my previos tests over the night, and the data always
> turned out to be OK, not a single byte turned out kaput!
> 
> I wish I would have tested that earlier, and spared you the noise... well,
> maybe someone who runs into a similar problem in the future will have this
> discovery save her/him some time and headaches and make her/him just upgrade
> kernels :)
> 
> Thanks a lot for your polite and quick responses!
> 

Nice to hear. Now we should make sure we have all needed fixes for prior
stable kernels as well !

Still trying to understand the issue, since I thought I only did
optimizations, not bug fixes. So maybe real bug is still there but its
probability of occurrence lowered enough to not hit your workload.
 
Hmmm...
