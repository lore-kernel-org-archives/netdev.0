From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/igmp.c: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Fri, 22 Aug 2014 12:28:10 -0700 (PDT)
Message-ID: <20140822.122810.1637401319817927091.davem@davemloft.net>
References: <20140817124941.GA14000@ada>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: bernat.ada@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140817124941.GA14000@ada>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Date: Sun, 17 Aug 2014 15:49:41 +0300

> The "rcu_dereference()" call is used directly in a condition.
> Since its return value is never dereferenced it is recommended to use
> "rcu_access_pointer()" instead of "rcu_dereference()".
> Therefore, this patch makes the replacement.
 ...
> Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>

Applied.
