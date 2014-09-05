From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] ipv6: fix rtnl locking in setsockopt for
 anycast and multicast
Date: Fri, 05 Sep 2014 11:53:05 -0700 (PDT)
Message-ID: <20140905.115305.809714259412705649.davem@davemloft.net>
References: <20140901210520.GB25543@kria>
	<1409610378.21965.52.camel@localhost>
	<20140902082929.GA8483@kria>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, cwang@twopensource.com,
	tt.rantala@gmail.com, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trinity@vger.kernel.org,
	davej@redhat.com
To: sd@queasysnail.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140902082929.GA8483@kria>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 2 Sep 2014 10:29:29 +0200

> Calling setsockopt with IPV6_JOIN_ANYCAST or IPV6_LEAVE_ANYCAST
> triggers the assertion in addrconf_join_solict()/addrconf_leave_solict()
> 
> ipv6_sock_ac_join(), ipv6_sock_ac_drop(), ipv6_sock_ac_close() need to
> take RTNL before calling ipv6_dev_ac_inc/dec. Same thing with
> ipv6_sock_mc_join(), ipv6_sock_mc_drop(), ipv6_sock_mc_close() before
> calling ipv6_dev_mc_inc/dec.
> 
> This patch moves ASSERT_RTNL() up a level in the call stack.
> 
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> Reported-by: Tommi Rantala <tt.rantala@gmail.com>

Applied and queued up for -stable, thanks.
