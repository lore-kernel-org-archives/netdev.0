From: Paul Wouters <paul@xelerance.com>
Subject: Re: [Openswan dev] Re: [IPSEC] COW skb header in UDP decap
Date: Wed, 20 Apr 2005 16:10:01 +0200 (MET DST)
Message-ID: <Pine.LNX.4.61.0504201609160.29370@expansionpack.xtdnet.nl>
References: <21730.1112984853@marajade.sandelman.ottawa.on.ca>
	<20050419231741.64e44443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: dev@lists.openswan.org
Return-path: <dev-bounces@openswan.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050419231741.64e44443.davem@davemloft.net>
Cc: Michael Richardson <mcr@sandelman.ottawa.on.ca>
Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: netdev@oss.sgi.com
List-Unsubscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=unsubscribe>
List-Archive: <http://lists.openswan.org/pipermail/dev>
List-Post: <mailto:dev@openswan.org>
List-Help: <mailto:dev-request@openswan.org?subject=help>
List-Subscribe: <http://lists.openswan.org/mailman/listinfo/dev>,
	<mailto:dev-request@openswan.org?subject=subscribe>
Sender: dev-bounces@openswan.org
Errors-To: dev-bounces@openswan.org
List-Id: netdev.vger.kernel.org

On Tue, 19 Apr 2005, David S. Miller wrote:

>> Thanks for the patch.  I think we can use something a little lighter
>> than skb_unshare.  The following patch just makes the header part of
>> the skb writeable.  This is needed since we modify the IP headers
>> just a few lines below.
>>
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
>
> Applied, thanks a lot Herbert.

Which reminds me. I still have hanging 'ip xfrm state' commands on 2.6.11.7

Paul
