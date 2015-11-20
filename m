From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET v2] netfilter, cgroup: implement xt_cgroup2 match
Date: Fri, 20 Nov 2015 16:06:02 -0500
Message-ID: <20151120210602.GD1574@mtj.duckdns.org>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
 <20151120.135912.1506496112678349111.davem@davemloft.net>
 <20151120195625.GA1124@salvia>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151120195625.GA1124@salvia>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, David, Pablo.

On Fri, Nov 20, 2015 at 08:56:25PM +0100, Pablo Neira Ayuso wrote:
> > Pablo, are you ok with me merging this into net-next directly or
> > would you rather I take patches 1-6 into net-next and then you can
> > merge and then add patch #7 on top?
> 
> I'd suggest you get 1-6, then I'll pull this info my tree. Thanks David!

Hmm.... 1-3 will be needed to address similar issues in a different
controller, so putting them in a separate branch would work best.  I
created a branch which contains the 1-3 on top of v4.4-rc1.

  git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-4.5-ancestor-test

If creating a different branch from net side is better, please let me
know.

> Regarding #7, I have a couple two concerns:
> 
> 1) cgroup currently doesn't work the way users expect, ie. to perform any
>    reasonable firewalling. Since this relies on early demux, only a
>    limited number of sockets get access to the cgroup info.

Right, it doesn't work well on INPUT side, so the big warning in the
man page.

> 2) We have traditionally rejected match2 and target2 extensions. I
>    guess you can accomodate the new cgroup code through the revision
>    iptables infrastructure, so we still use the cgroup match.

I thought it would be confusing because the two are completely
separate.  Hmmm... okay, I'll merge it into xt_cgroup.

Thanks.

-- 
tejun
