From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: inconsistent lock state
Date: Mon, 21 Jun 2010 08:54:52 +0200
Message-ID: <1277103292.1875.331.camel@laptop>
References: <20100615112434.GA3967@swordfish.minsk.epam.com>
	 <20100618133004.228c2223.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Sage Weil <sage@newdream.net>, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Dominik Brodowski <linux@dominikbrodowski.net>,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Paul E.McKenney" <paulmck@linux.vnet.ibm.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	"David S.Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:43803 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754428Ab0FUIN3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jun 2010 04:13:29 -0400
In-Reply-To: <20100618133004.228c2223.akpm@linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-06-18 at 13:30 -0700, Andrew Morton wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> 
> Fix a lockdep-splat-causing regression introduced by
> 
> : commit 989a2979205dd34269382b357e6d4b4b6956b889
> : Author:     Eric Dumazet <eric.dumazet@gmail.com>
> : AuthorDate: Wed Apr 14 09:55:35 2010 +0000
> : Commit:     David S. Miller <davem@davemloft.net>
> : CommitDate: Wed Apr 21 16:19:29 2010 -0700
> : 
> :     fasync: RCU and fine grained locking
> 
> kill_fasync() can be called from both process and hard-irq context, so
> fa_lock must be taken with IRQs disabled.
> 
> Addresses https://bugzilla.kernel.org/show_bug.cgi?id=16230
> 
> Reported-by: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>
> Reported-by: Dominik Brodowski <linux@dominikbrodowski.net>
> Cc: Maciej Rutecki <maciej.rutecki@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
> Cc: Lai Jiangshan <laijs@cn.fujitsu.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Andrew Morton <akpm@linux-foundation.org> 

Acked-by: Peter Zijlstra <a.p.zijlstra@chello.nl>
