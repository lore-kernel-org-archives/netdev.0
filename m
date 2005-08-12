From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Fri, 12 Aug 2005 12:09:04 -0700 (PDT)
Message-ID: <20050812.120904.88476024.davem@davemloft.net>
References: <20050812153730.GR18580@rama.de.gnumonks.org>
	<20050812182355.GF22901@wotan.suse.de>
	<20050812190343.GW18580@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net, ak@suse.de
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050812190343.GW18580@rama.de.gnumonks.org>
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

From: Harald Welte <laforge@netfilter.org>
Date: Fri, 12 Aug 2005 21:03:43 +0200

> Ok, I hope everyone is fine with this patch:

It is, but I did not add the connbytes patch into my tree so I can't
use this patch as-is.  That's why I replied "this is broken, fix u64
alignment" to the connbytes patch instead of "applied, thanks" :-)

Please untangle this stuff.  This is how we end up with a big mess of
noise changesets in the tree, due to how we have been putting
half-working changes in first then a bunch of "fixup" patches.  I'd
like to avoid that, because I then spend a lot of time redoing things
when I rebase the tree later.

So in this case, send me the aligned_u64 patch seperately which
doesn't assume connbytes is in the tree.  Then another patch which
adds connbytes with the proper usage of aligned_u64.

Thanks Harald.
