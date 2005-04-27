From: Patrick McHardy <kaber@trash.net>
Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
Date: Wed, 27 Apr 2005 12:26:13 +0200
Message-ID: <426F68C5.4010109@trash.net>
References: <E1DQ1Ct-00055s-00@gondolin.me.apana.org.au>
	<426D0CB9.4060500@trash.net>
	<20050425213400.GB29288@gondor.apana.org.au>
	<426D8672.1030001@trash.net>
	<20050426003925.GA13650@gondor.apana.org.au>
	<426E3F67.8090006@trash.net>
	<20050426232857.GA18358@gondor.apana.org.au>
	<426EE350.1070902@trash.net>
	<20050427010730.GA18919@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org, Yair@arx.com,
	linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050427010730.GA18919@gondor.apana.org.au>
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

Herbert Xu wrote:
> Couldn't we feed the TCP RST packets with foreign sources through
> the FORWARD table? We're lying to the routing system already by
> telling it that the packet is forwarded.  So I don't see anything
> wrong with lying to netfilter as well :)

Forwarded packets can't have any NAT manips in LOCAL_OUT, so it
should work. I'm not sure about it though because it would be
the only place where packets just appear in FORWARD, usually
all packets enters through PRE_ROUTING or LOCAL_OUT.

Regards
Patrick
