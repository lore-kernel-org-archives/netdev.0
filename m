From: Patrick McHardy <kaber@trash.net>
Subject: Re: [17/*] [NET] Replace dst_pmtu with dst_mtu
Date: Tue, 15 Mar 2005 20:02:26 +0100
Message-ID: <42373142.6090902@trash.net>
References: <20050214221433.GB18465@gondor.apana.org.au>	<20050214221607.GC18465@gondor.apana.org.au>	<20050306213214.7d8a143d.davem@davemloft.net>	<20050307103536.GB7137@gondor.apana.org.au>	<20050308102741.GA23468@gondor.apana.org.au>	<20050314102614.GA9610@gondor.apana.org.au>	<20050314105313.GA21001@gondor.apana.org.au>	<20050314111002.GA29156@gondor.apana.org.au>	<20050315091904.GA6256@gondor.apana.org.au>	<20050315095837.GA7130@gondor.apana.org.au>	<20050315100522.GA7275@gondor.apana.org.au>
	<20050315102450.0f3f1618.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	Herbert Xu <herbert@gondor.apana.org.au>, netdev@oss.sgi.com
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050315102450.0f3f1618.davem@davemloft.net>
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

David S. Miller wrote:
> On Tue, 15 Mar 2005 21:05:22 +1100
> Herbert Xu <herbert@gondor.apana.org.au> wrote:
> 
>>At this point the only remaining user of dst_pmtu is ipt_REJECT which
>>will go away either when we use icmp_send in there or when I replace
>>it with dst_mtu.
> 
> 
> Yes, I saw that posting on netfilter-devel where you asked Rusty
> why icmp_send() wasn't directly used even though it appears it
> should be.

I would prefer to keep it seperately. I have planned to remove xrlim
from ipt_REJECT so it behaves similar for TCP and ICMP. Limits should
then be handled by the limit match. This can't be done if we switch to
icmp_send().

Regards
Patrick
