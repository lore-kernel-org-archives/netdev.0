From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/openvswitch/flow.c: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Fri, 22 Aug 2014 12:28:20 -0700 (PDT)
Message-ID: <20140822.122820.711926786446707941.davem@davemloft.net>
References: <20140817132943.GA2142@ada>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pshelar@nicira.com, dev@openvswitch.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: bernat.ada@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140817132943.GA2142@ada>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Date: Sun, 17 Aug 2014 16:29:43 +0300

> The "rcu_dereference()" call is used directly in a condition.
> Since its return value is never dereferenced it is recommended to use
> "rcu_access_pointer()" instead of "rcu_dereference()".
> Therefore, this patch makes the replacement.
 ...
> Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>

Applied.
