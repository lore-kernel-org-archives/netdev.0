From: Patrick McHardy <kaber@trash.net>
Subject: Re: Re-routing packets via netfilter (ip_rt_bug)
Date: Tue, 26 Apr 2005 02:08:18 +0200
Message-ID: <426D8672.1030001@trash.net>
References: <E1DQ1Ct-00055s-00@gondolin.me.apana.org.au>
	<426D0CB9.4060500@trash.net>
	<20050425213400.GB29288@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, netfilter-devel@lists.netfilter.org, Yair@arx.com,
	linux-kernel@vger.kernel.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20050425213400.GB29288@gondor.apana.org.au>
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
> You're right.  But then we can't call ip_route_output in the case
> where saddr is foreign but daddr is local.  Nor can we call
> ip_route_input since the output will be ip_rt_bug.

In that case we need to use saddr=0, which shouldn't make any difference
with sane routing.

Regards
Patrick
