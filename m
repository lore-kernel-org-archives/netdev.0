From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] cls_cgroup: Fix rcu lockdep warning
Date: Fri, 03 Sep 2010 09:55:39 -0700 (PDT)
Message-ID: <20100903.095539.220051635.davem@davemloft.net>
References: <4C805293.1020305@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.hengli.com.au, davej@redhat.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	peterz@infradead.org, menage@google.com
To: lizf@cn.fujitsu.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C805293.1020305@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Li Zefan <lizf@cn.fujitsu.com>
Date: Fri, 03 Sep 2010 09:42:43 +0800

> Dave reported an rcu lockdep warning on 2.6.35.4 kernel
> 
> task->cgroups and task->cgroups->subsys[i] are protected by RCU.
> So we avoid accessing invalid pointers here. This might happen,
> for example, when you are deref-ing those pointers while someone
> move @task from one cgroup to another.
> 
> Reported-by: Dave Jones <davej@redhat.com>
> Signed-off-by: Li Zefan <lizf@cn.fujitsu.com>

Applied, thanks.
