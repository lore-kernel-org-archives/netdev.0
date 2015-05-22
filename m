From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv4: fill in table id when replacing a route
Date: Fri, 22 May 2015 14:35:31 -0400 (EDT)
Message-ID: <20150522.143531.751560653519778934.davem@davemloft.net>
References: <20150522114009.043A6A0CCC@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alexander.h.duyck@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net
To: mkubecek@suse.cz
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150522114009.043A6A0CCC@unicorn.suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Michal Kubecek <mkubecek@suse.cz>
Date: Fri, 22 May 2015 13:40:09 +0200 (CEST)

> When replacing an IPv4 route, tb_id member of the new fib_alias
> structure is not set in the replace code path so that the new route is
> ignored.
> 
> Fixes: 0ddcf43d5d4a ("ipv4: FIB Local/MAIN table collapse")
> 
> Signed-off-by: Michal Kubecek <mkubecek@suse.cz>

Applied, thanks.

In the future, please do not put an empty line between the Fixes: and
other tags.  I fixed it up for you this time.  Thanks.
