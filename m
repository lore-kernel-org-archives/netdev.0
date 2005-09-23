From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [NETFILTER] fix conntrack event cache deadlock
Date: Thu, 22 Sep 2005 23:47:24 -0700 (PDT)
Message-ID: <20050922.234724.110942393.davem@davemloft.net>
References: <20050922143515.GD8917@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050922143515.GD8917@rama.de.gnumonks.org>
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
Date: Thu, 22 Sep 2005 16:35:15 +0200

> [NETFILTER] Fix conntrack event cache deadlock/oops

Applied.  I hope that doing the event cache call outside
the lock is safe?  It was not depending upon that protection
in any way was it?

Thanks Harald.
