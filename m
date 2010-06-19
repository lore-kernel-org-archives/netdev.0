From: Dominik Brodowski <linux@dominikbrodowski.net>
Subject: Re: inconsistent lock state
Date: Sat, 19 Jun 2010 15:05:47 +0200
Message-ID: <20100619130547.GA6424@comet.dominikbrodowski.net>
References: <20100615112434.GA3967@swordfish.minsk.epam.com>
 <20100618133004.228c2223.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Sergey Senozhatsky <sergey.senozhatsky@gmail.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	Sage Weil <sage@newdream.net>, linux-fsdevel@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Maciej Rutecki <maciej.rutecki@gmail.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20100618133004.228c2223.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hey,

On Fri, Jun 18, 2010 at 01:30:04PM -0700, Andrew Morton wrote:
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

Seems to work fine -- thanks!

Best,
	Dominik
