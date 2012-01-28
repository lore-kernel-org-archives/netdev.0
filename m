From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] netns: Fail conspicously if someone uses
 net_generic at an inappropriate time.
Date: Fri, 27 Jan 2012 21:07:06 -0500 (EST)
Message-ID: <20120127.210706.1819458801435039273.davem@davemloft.net>
References: <m1zkdacbsx.fsf@fess.ebiederm.org>
	<20120126.180754.679593869814492219.davem@davemloft.net>
	<m1ehumc8r4.fsf_-_@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, xemul@parallels.com,
	sjur.brandeland@stericsson.com, levinsasha928@gmail.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davej@redhat.com, sjurbren@gmail.com
To: ebiederm@xmission.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <m1ehumc8r4.fsf_-_@fess.ebiederm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Thu, 26 Jan 2012 16:02:55 -0800

> By definition net_generic should never be called when it can return
> NULL.  Fail conspicously with a BUG_ON to make it clear when people mess
> up that a NULL return should never happen.
> 
> Recently there was a bug in the CAIF subsystem where it was registered
> with register_pernet_device instead of register_pernet_subsys.  It was
> erroneously concluded that net_generic could validly return NULL and
> that net_assign_generic was buggy (when it was just inefficient).
> Hopefully this BUG_ON will prevent people to coming to similar erroneous
> conclusions in the futrue.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Applied.
