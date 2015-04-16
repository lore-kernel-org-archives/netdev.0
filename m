From: David Miller <davem@davemloft.net>
Subject: Re: [v3] skbuff: Do not scrub skb mark within the same name space
Date: Thu, 16 Apr 2015 14:21:24 -0400 (EDT)
Message-ID: <20150416.142124.1721494984301782904.davem@davemloft.net>
References: <552E86A6.9000101@6wind.com>
	<20150416010326.GA10864@gondor.apana.org.au>
	<20150416083335.GE32170@casper.infradead.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, nicolas.dichtel@6wind.com,
	netdev@vger.kernel.org, ebiederm@xmission.com, jmorris@namei.org,
	linux-security-module@vger.kernel.org
To: tgraf@suug.ch
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <20150416083335.GE32170@casper.infradead.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Thomas Graf <tgraf@suug.ch>
Date: Thu, 16 Apr 2015 09:33:35 +0100

> On 04/16/15 at 09:03am, Herbert Xu wrote:
>> The commit ea23192e8e577dfc51e0f4fc5ca113af334edff9 ("tunnels:
>> harmonize cleanup done on skb on rx path") broke anyone trying to
>> use netfilter marking across IPv4 tunnels.  While most of the
>> fields that are cleared by skb_scrub_packet don't matter, the
>> netfilter mark must be preserved.
>> 
>> This patch rearranges skb_scrub_packet to preserve the mark field.
>> 
>> Fixes: ea23192e8e57 ("tunnels: harmonize cleanup done on skb on rx path")
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Acked-by: Thomas Graf <tgraf@suug.ch>
> 
> We should also add a flag to veth which expclitly allows to preserve
> the mark into the namespace.

Applied and queued up for -stable, thanks.
