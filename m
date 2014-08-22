From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] bonding: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Fri, 22 Aug 2014 12:28:01 -0700 (PDT)
Message-ID: <20140822.122801.607834249912014517.davem@davemloft.net>
References: <20140817102145.GA3854@ada>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: j.vosburgh@gmail.com, vfalico@gmail.com, andy@greyhouse.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	paulmck@linux.vnet.ibm.com
To: bernat.ada@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140817102145.GA3854@ada>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Date: Sun, 17 Aug 2014 13:21:45 +0300

> This "rcu_dereference()" call is used directly in a condition.
> Since its return value is never dereferenced it is recommended to use
> "rcu_access_pointer()" instead of "rcu_dereference()".
> Therefore, this patch makes this replacement.
 ...
> Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>

Applied.
