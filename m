From: "David S. Miller" <davem@davemloft.net>
Subject: Re: masquerading failure for at least icmp and tcp+sack on amd64
Date: Tue, 13 Sep 2005 20:41:50 -0700 (PDT)
Message-ID: <20050913.204150.99694717.davem@davemloft.net>
References: <20050913110902.0ad58b90@localhost.localdomain>
	<20050913.135954.111731835.davem@davemloft.net>
	<43277943.8050700@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@osdl.org, netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	schmorp@schmorp.de, shemminger@osdl.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: kaber@trash.net
In-Reply-To: <43277943.8050700@trash.net>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Wed, 14 Sep 2005 03:13:39 +0200

> David S. Miller wrote:
> > I personally think netfilter should do so.
> 
> I agree. One thing I've planned for some silent moment is
> to clean up the entire netfilter checksumming code (there's
> lots of small duplicated chunks). Probably at least some
> of it will also be applicable for the remaining stack.

There is another thing I thought about today, and that is
to automatically handle this CHECKSUM_HW stuff when the
skb->data area is COW'd via pskb_expand_head() or similar.

I don't know how well that would work, but if it did then
we could consolidate all of this stuff into one spot which
is always nice.
