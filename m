From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] Inet-hashtable: Change the range of sk->hash lock to
 avoid the race condition.
Date: Thu, 12 Sep 2013 05:00:04 -0700
Message-ID: <1378987204.24408.1.camel@edumazet-glaptop>
References: <1379003549.12328.6.camel@chenjun-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Jun Chen <jun.d.chen@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1379003549.12328.6.camel@chenjun-workstation>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-09-12 at 12:32 -0400, Jun Chen wrote:
> When try to add node to list in __inet_hash_nolisten function, first get the
> list and then to lock for using, but in extremeness case, others can del this
> node before locking it, then the node should be null.So this patch try to lock
> firstly and then get the list for using to avoid this race condition.

I suspect another bug. This should not happen.

Care to describe the problem you got ?

Thanks
