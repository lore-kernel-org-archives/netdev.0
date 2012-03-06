From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 6/6] netfilter: nf_conntrack: fix early_drop with
 reliable event delivery
Date: Tue, 06 Mar 2012 15:16:18 -0500 (EST)
Message-ID: <20120306.151618.683601515842945468.davem@davemloft.net>
References: <1331032975-5303-1-git-send-email-pablo@netfilter.org>
	<1331032975-5303-7-git-send-email-pablo@netfilter.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: pablo@netfilter.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1331032975-5303-7-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: pablo@netfilter.org
Date: Tue,  6 Mar 2012 12:22:55 +0100

> From: Pablo Neira Ayuso <pablo@netfilter.org>
> 
> If reliable event delivery is enabled and ctnetlink fails to deliver
> the destroy event in early_drop, the conntrack subsystem cannot
> drop any the candidate flow that was planned to be evicted.
> 
> Reported-by: Kerin Millar <kerframil@gmail.com>
> Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>

Applied.

> +		/* Check if we indeed killed this entry. Reliable event
> +		   delivery may have inserted it into the dying list. */
> +		if (test_bit(IPS_DYING_BIT, &ct->status)) {

Please don't allow misformatted comments like this into your
tree next time, this should be:

		/* Check if we indeed killed this entry. Reliable event
		 * delivery may have inserted it into the dying list.
		 */
