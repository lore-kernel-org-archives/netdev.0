From: David Miller <davem@davemloft.net>
Subject: Re: ctnetlink loop
Date: Fri, 10 Dec 2010 14:01:46 -0800 (PST)
Message-ID: <20101210.140146.68123509.davem@davemloft.net>
References: <20101203133903.GG13225@mail.eitzenberger.org>
	<4D00B5CD.3050406@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@lists.netfilter.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: pablo@netfilter.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4D00B5CD.3050406@netfilter.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Pablo Neira Ayuso <pablo@netfilter.org>
Date: Thu, 09 Dec 2010 11:56:13 +0100

> netfilter: ctnetlink: fix loop in ctnetlink_get_conntrack()
> 
> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> This patch fixes a loop in ctnetlink_get_conntrack() that can be
> triggered if you use the same socket to receive events and to
> perform a GET operation. Under heavy load, netlink_unicast()
> may return -EAGAIN, this error code is reserved in nfnetlink for
> the module load-on-demand. Instead, we return -ENOBUFS which is
> the appropriate error code that has to be propagated to
> user-space.
> 
> Reported-by: Holger Eitzenberger <holger@eitzenberger.org>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Since Patrick seems to be inactive I have applied this directly
to net-2.6, thanks guys!
