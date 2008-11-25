From: David Miller <davem@davemloft.net>
Subject: Re: bridge 03/03: netfilter: fix update_pmtu crash with GRE
Date: Mon, 24 Nov 2008 16:07:01 -0800 (PST)
Message-ID: <20081124.160701.107956737.davem@davemloft.net>
References: <20081124134427.462.77824.sendpatchset@x2.localnet>
	<20081124134431.462.53634.sendpatchset@x2.localnet>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@vger.kernel.org
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <20081124134431.462.53634.sendpatchset@x2.localnet>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 24 Nov 2008 14:44:39 +0100 (MET)

>     bridge: netfilter: fix update_pmtu crash with GRE
>     
>     As GRE tries to call the update_pmtu function on skb->dst and
>     bridge supplies an skb->dst that has a NULL ops field, all is
>     not well.
>     
>     This patch fixes this by giving the bridge device an ops field
>     with an update_pmtu function.  For the moment I've left all
>     other fields blank but we can fill them in later should the
>     need arise.
>     
>     Based on report and patch by Philip Craig.
>     
>     Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>     Signed-off-by: Patrick McHardy <kaber@trash.net>

Applied.
