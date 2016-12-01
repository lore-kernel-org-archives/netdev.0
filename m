From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net] tipc: check minimum bearer MTU
Date: Thu, 1 Dec 2016 18:07:47 +0800
Message-ID: <2993fe74-a4d3-55ea-c600-ade0f0ee3a02@windriver.com>
References: <20161130095702.DD033A0F14@unicorn.suse.cz>
	<4a2da388-d798-11cf-bf2c-84207cae6159@windriver.com>
	<20161130132333.GD19119@unicorn.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>, Qian Zhang <zhangqian-c@360.cn>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net, Ben Hutchings <ben@decadent.org.uk>,
	"David S. Miller" <davem@davemloft.net>
To: Michal Kubecek <mkubecek@suse.cz>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <20161130132333.GD19119@unicorn.suse.cz>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

>>
>> For UDP bearer, it seems insufficient for us to check MTU size only
>> when UDP bearer is enabled. Meanwhile, we should update MTU size for
>> UDP bearer with Path MTU discovery protocol once MTU size is changed
>> after bearer is enabled.
>
> I should admit I'm not that familiar with tipc. Do you mean updating
> b->mtu in response to PMTU updates of the route used for ub->ubsock?

Yes.

> The way I understand it, it would be certainly useful but it's not
> directly related to the security issue this patch addresses as if there
> are no updates, b->mtu cannot get too low and there is no risk of
> a buffer overflow. In other words, reflecting PMTU updates is something
> that can be IMHO left for later.
>

Agreed.

Regards,
Ying

>                                                       Michal Kubecek
>


------------------------------------------------------------------------------
