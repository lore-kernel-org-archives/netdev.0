From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Fri, 12 Aug 2005 11:12:02 -0700 (PDT)
Message-ID: <20050812.111202.21596293.davem@davemloft.net>
References: <42FC8EBC.1070505@trash.net> <20050812120319.GK8974@wotan.suse.de>
	<20050812153730.GR18580@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org, ak@suse.de,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050812153730.GR18580@rama.de.gnumonks.org>
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
Date: Fri, 12 Aug 2005 17:37:30 +0200

> But getting back to the original connbytes issue.  Is it worth fixing
> it, if the core iptables doesn't even work (the "old bug")?

I think it is a good policy to not let in new code, regardless of
context, which uses __u64 in user visible structures a way we know
isn't compatible.

So please let's fix this up.
