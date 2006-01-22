From: Patrick McHardy <kaber@trash.net>
Subject: Re: ip_finish_output2: No header cache and no neighbour! in
	2.6.15-git7
Date: Sun, 22 Jan 2006 15:07:01 +0100
Message-ID: <43D39185.4070808@trash.net>
References: <20060116071515.GA1773@gondor.apana.org.au>	<43CCBC0E.4070701@trash.net>	<200601200815.40210.ak@suse.de>
	<20060119.235114.41595062.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	ak@suse.de, herbert@gondor.apana.org.au
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060119.235114.41595062.davem@davemloft.net>
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
> From: Andi Kleen <ak@suse.de>
> Date: Fri, 20 Jan 2006 08:15:39 +0100
> 
>>Sorry for the delay in testing. Looks good so far. I'm running with SNAT
>>and the patch and the messages haven't appeared. Will keep it running
>>for longer, but previously they would have started already, so it's probably
>>ok now.
> 
> 
> Thanks for testing Andi.
> 
> Patrick, please send me the final version of the fix you want me to
> put in when you get a chance.

I need to rethink this, my patch breaks SNAT to non-local IPs because
the NAT code will throw the packet away if ip_route_me_harder fails.
