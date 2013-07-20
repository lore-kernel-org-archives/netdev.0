From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bridge: do not call setup_timer() multiple times
Date: Fri, 19 Jul 2013 22:13:34 -0700 (PDT)
Message-ID: <20130719.221334.1029630301322767269.davem@davemloft.net>
References: <51E557C0.2060602@linux.vnet.ibm.com>
	<1374289636.26476.42.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: srivatsa.bhat@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
	tglx@linutronix.de, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1374289636.26476.42.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 19 Jul 2013 20:07:16 -0700

> From: Eric Dumazet <edumazet@google.com>
> 
> commit 9f00b2e7cf24 ("bridge: only expire the mdb entry when query is
> received") added a nasty bug as an active timer can be reinitialized.
> 
> setup_timer() must be done once, no matter how many time mod_timer()
> is called. br_multicast_new_group() is the right place to do this.
> 
> Reported-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> Diagnosed-by: Thomas Gleixner <tglx@linutronix.de>
> Signed-off-by: Eric Dumazet <edumazet@google.com>
> Tested-by: Srivatsa S. Bhat <srivatsa.bhat@linux.vnet.ibm.com>
> Cc: Cong Wang <amwang@redhat.com>

Applied, thanks a lot Eric.
