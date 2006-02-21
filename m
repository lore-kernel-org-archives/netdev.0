From: Patrick McHardy <kaber@trash.net>
Subject: Re: [NETFILTER]: Fix skb->nf_bridge lifetime issues
Date: Tue, 21 Feb 2006 05:17:04 +0100
Message-ID: <43FA9440.6070103@trash.net>
References: <43F97342.9050806@trash.net>	<43F98CEE.1080609@trash.net>
	<20060220.200943.51907116.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org,
	bdschuym@pandora.be
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060220.200943.51907116.davem@davemloft.net>
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
> From: Patrick McHardy <kaber@trash.net>
> Date: Mon, 20 Feb 2006 10:33:34 +0100
> 
> 
>>This time compile tested and s/nfct/nf_bridge/ above.
> 
> 
> Want me to push this into net-2.6 now that Bart has ACK'd it?

I think net-2.6.17 is better, the bridging stuff is really to
fragile for this to be sure it won't break anything and this
has never worked so far.
