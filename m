From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] cnic: Replace rcu_dereference() with
 rcu_access_pointer()
Date: Fri, 22 Aug 2014 12:27:51 -0700 (PDT)
Message-ID: <20140822.122751.953073827713209046.davem@davemloft.net>
References: <20140817101149.GA3692@ada>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mchan@broadcom.com, eddie.wai@broadcom.com, joe@perches.com,
	mingo@kernel.org, peterz@infradead.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, paulmck@linux.vnet.ibm.com
To: bernat.ada@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53501 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751719AbaHVT1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Aug 2014 15:27:52 -0400
In-Reply-To: <20140817101149.GA3692@ada>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andreea-Cristina Bernat <bernat.ada@gmail.com>
Date: Sun, 17 Aug 2014 13:12:09 +0300

> The "rcu_dereference()" calls are used directly in conditions.
> Since their return values are never dereferenced it is recommended to use
> "rcu_access_pointer()" instead of "rcu_dereference()".
> Therefore, this patch makes the replacements.
 ...
> Signed-off-by: Andreea-Cristina Bernat <bernat.ada@gmail.com>

Applied.
