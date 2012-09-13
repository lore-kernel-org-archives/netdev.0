From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v4 0/8] cgroup: Assign subsystem IDs during compile time
Date: Thu, 13 Sep 2012 11:13:02 -0700
Message-ID: <20120913181302.GE7677@google.com>
References: <1347459128-32236-1-git-send-email-wagi@monom.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	Daniel Wagner <daniel.wagner@bmw-carit.de>,
	"David S. Miller" <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	Eric Dumazet <edumazet@google.com>,
	Gao feng <gaofeng@cn.fujitsu.com>,
	Glauber Costa <glommer@parallels.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>,
	Li Zefan <lizefan@huawei.com>,
	Neil Horman <nhorman@tuxdriver.com>
To: Daniel Wagner <wagi@monom.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:42082 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755292Ab2IMSNH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 14:13:07 -0400
Content-Disposition: inline
In-Reply-To: <1347459128-32236-1-git-send-email-wagi@monom.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 12, 2012 at 04:12:00PM +0200, Daniel Wagner wrote:
> I've removed the useless test in patch #4 and updated the commit message
> on patch #7. 
> 
> While rewriting the commit message #7 I realized the pointer check was
> completely wrong. Instead testing the return value of
> task_subsys_state() I tested the pointer return by container_of. For
> more details on this see the commit message. 
> 
> Because of this I added Herbert and Paul to the Cc list. Please have
> close look at my rambling on the RCU part in patch #7. Thanks a lot!
> 
> This series is against 
> 
>      git://git.kernel.org/pub/scm/linux/kernel/git/tj/cgroup.git for-3.7

Applied to cgroup/for-3.7.

Thanks!

-- 
tejun
