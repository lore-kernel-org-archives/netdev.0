From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: Fw: rcu warning
Date: Wed, 22 Sep 2010 14:47:36 -0700
Message-ID: <20100922144736.baf75544.akpm@linux-foundation.org>
References: <20100922214438.GN2435@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org
To: paulmck@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:50673 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750913Ab0IVVri (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Sep 2010 17:47:38 -0400
In-Reply-To: <20100922214438.GN2435@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 22 Sep 2010 14:44:38 -0700
"Paul E. McKenney" <paulmck@linux.vnet.ibm.com> wrote:

> In linux/master, there is an rcu_read_lock_bh() in the call path, but
> an rcu_dereference() instead of an rcu_dereference_bh().  Thoughts?
> 
> (I have asked Andrew what kernel this is against -- I don't see the
> rcu_read_lock() that I would expect to see in the lockdep output.)

current linux-next.
