From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ucc_geth: Add support for skb recycling
Date: Tue, 07 Jul 2009 19:23:07 -0700 (PDT)
Message-ID: <20090707.192307.222215206.davem@davemloft.net>
References: <20090707183842.GA8425@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, leoli@freescale.com, afleming@freescale.com,
	linuxppc-dev@ozlabs.org
To: avorontsov@ru.mvista.com
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <20090707183842.GA8425@oksana.dev.rtsoft.ru>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

From: Anton Vorontsov <avorontsov@ru.mvista.com>
Date: Tue, 7 Jul 2009 22:38:42 +0400

> We can reclaim transmitted skbs to use in the receive path, so-called
> skb recycling support.
> 
> Also reorder ucc_geth_poll() steps, so that we'll clean tx ring firstly,
> thus maybe reclaim some skbs for rx.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>

Applied to net-next-2.6
