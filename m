From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [RFC] MASQUERADE / policy routing ("Route send us somewhere
 else")
Date: Mon, 30 Aug 2004 19:24:58 -0700
Sender: netfilter-devel-bounces@lists.netfilter.org
Message-ID: <20040830192458.1476df60.davem@davemloft.net>
References: <20040831013841.GA5824@sunbeam.de.gnumonks.org>
	<E1C1yGT-000859-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: laforge@netfilter.org, netdev@oss.sgi.com, rusty@rustcorp.com.au,
	netfilter-devel@lists.netfilter.org, kuznet@ms2.inr.ac.ru
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1C1yGT-000859-00@gondolin.me.apana.org.au>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

On Tue, 31 Aug 2004 12:20:53 +1000
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> So it would be good to know why the oif key is a bad idea.

I'm OK with removing the oif check, but I'm not OK with the
idea of specifying a specific output interface in the
route lookup flow key here.
