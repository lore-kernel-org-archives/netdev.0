From: Patrick McHardy <kaber@trash.net>
Subject: Re: [RFC, PATCH 3/5]: netfilter+ipsec - input hooks
Date: Fri, 19 Mar 2004 17:17:30 +0100
Sender: netfilter-devel-admin@lists.netfilter.org
Message-ID: <405B1D1A.6050700@trash.net>
References: <20040308110331.GA20719@gondor.apana.org.au>	<404C874D.4000907@trash.net>	<20040308115858.75cdddca.davem@redhat.com>	<4059CF0E.3050708@trash.net> <20040318221523.07298f03.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au,  netdev@oss.sgi.com,
 netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-admin@lists.netfilter.org>
To: "David S. Miller" <davem@redhat.com>
In-Reply-To: <20040318221523.07298f03.davem@redhat.com>
Errors-To: netfilter-devel-admin@lists.netfilter.org
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: <https://lists.netfilter.org/pipermail/netfilter-devel/>
List-Id: netdev.vger.kernel.org

David S. Miller wrote:
> 
> Be careful!  xfrm4_tunnel handles both uncompressed ipcomp packets
> _and_ IPIP encapsulator device packets.  Yet you will intepret usage
> of the ipprot as 'xfrm_prot==1' in all cases.
> 
> Yes this is ugly... if we added some kind of flag bit-mask to sk_buff,
> would that allow an easier implementation?
> 

I can't imagine how. Best would be to avoid the xfrm_prot flag
completely. Maybe we can add a flag to xfrm_state which indicates
that this is the last xfrm specified in the policy ?
