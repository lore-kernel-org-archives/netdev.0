From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH 2/7] kernfs: implement kernfs_walk_and_get()
Date: Fri, 20 Nov 2015 16:12:54 -0500
Message-ID: <20151120211254.GE1574@mtj.duckdns.org>
References: <1447959171-20749-1-git-send-email-tj@kernel.org>
 <1447959171-20749-3-git-send-email-tj@kernel.org>
 <20151120044104.GA10693@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	daniel@iogearbox.net, daniel.wagner@bmw-carit.de,
	nhorman@tuxdriver.com
To: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151120044104.GA10693@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 19, 2015 at 08:41:04PM -0800, Greg Kroah-Hartman wrote:
> On Thu, Nov 19, 2015 at 01:52:46PM -0500, Tejun Heo wrote:
> > Implement kernfs_walk_and_get() which is similar to
> > kernfs_find_and_get() but can walk a path instead of just a name.
> > 
> > v2: Use strlcpy() instead of strlen() + memcpy() as suggested by
> >     David.
> > 
> > Signed-off-by: Tejun Heo <tj@kernel.org>
> > Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>
> > Cc: David Miller <davem@davemloft.net>
> > ---
> >  fs/kernfs/dir.c        | 46 ++++++++++++++++++++++++++++++++++++++++++++++
> >  include/linux/kernfs.h | 12 ++++++++++++
> >  2 files changed, 58 insertions(+)
> 
> Acked-by: Greg Kroah-Hartman <gregkh@linuxfoundation.org>

Greg, would it be okay to route this one through either cgroup or net
tree?

Thanks.

-- 
tejun
