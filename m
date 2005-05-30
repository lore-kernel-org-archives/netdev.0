From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] fix deadlock with ip_queue and tcp local input path
Date: Mon, 30 May 2005 15:26:13 -0700 (PDT)
Message-ID: <20050530.152613.78709308.davem@davemloft.net>
References: <20050526142420.GD13114@sunbeam.de.gnumonks.org>
	<20050530180654.GX22760@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050530180654.GX22760@sunbeam.de.gnumonks.org>
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
Date: Mon, 30 May 2005 20:06:54 +0200

> I've now tested the suggested solution by Patrick McHardy and Herbert Xu to
> simply use local_bh_{en,dis}able().
> 
> Please apply the following patch to mainline.

Will do.

> btw: How do we get this into 2.6.11.x ?

You submit your patch to stable@kernel.org.

But I will take care of this for you Harald, don't
worry about it.
