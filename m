From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Frequent Oops on Shutdown 2.6.10
Date: Tue, 22 Feb 2005 20:57:19 +1100
Message-ID: <E1D3Wn9-00071h-00@gondolin.me.apana.org.au>
References: <20050221.162949.65179228.yoshfuji@linux-ipv6.org>
Cc: AndyLiebman@aol.com, terryg@axian.com, netdev@oss.sgi.com,
        davem@davemloft.net, akpm@osdl.org, yoshfuji@linux-ipv6.org
To: yoshfuji@linux-ipv6.org (YOSHIFUJI Hideaki / ????)
In-Reply-To: <20050221.162949.65179228.yoshfuji@linux-ipv6.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> wrote:
> In article <20050221.162241.24618885.yoshfuji@linux-ipv6.org> (at Mon, 21 Feb 2005 16:22:41 +0900 (JST)), YOSHIFUJI Hideaki / ???? <yoshfuji@linux-ipv6.org> says:
> 
>> [IPV6] Don't remove dev_snmp6 procfs entry until all users gone.

Sorry, but I don't see how this patch explains the oops the
people saw.

I googled for this oops and found three distinct occurences.  They
share the property that idev->stats.proc_dir_entry->name contains
a bogus value.  In two cases it had 0x5 and 0xa respectively, in
the other it had 0x61696265.

The last one could be an important clue.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
