From: Pekka Enberg <penberg@kernel.org>
Subject: Re: [PATCH 2/4] slub,rcu: don't assume the size of struct rcu_head
Date: Tue, 1 Mar 2011 15:00:02 +0200
Message-ID: <AANLkTimXy2Yaj+NTDMNTWuLqHHfKZJhVDpeXj3CfMvBf@mail.gmail.com>
References: <4D6CA852.3060303@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Ingo Molnar <mingo@elte.hu>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Christoph Lameter <cl@linux-foundation.org>, Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, Matt Mackall <mpm@selenic.com>, linux-mm@kvack.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Lai Jiangshan <laijs@cn.fujitsu.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <4D6CA852.3060303@cn.fujitsu.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, Mar 1, 2011 at 10:03 AM, Lai Jiangshan <laijs@cn.fujitsu.com> wrote:
> The size of struct rcu_head may be changed. When it becomes larger,
> it will pollute the page array.
>
> We reserve some some bytes for struct rcu_head when a slab
> is allocated in this situation.
>
> Signed-off-by: Lai Jiangshan <laijs@cn.fujitsu.com>

The SLAB and SLUB patches are fine by me if there are going to be real
users for this. Christoph, Paul?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
