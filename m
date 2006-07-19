From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [RFC PATCH 32/33] Add the Xen virtual network
	device driver.
Date: Wed, 19 Jul 2006 13:55:13 +1000
Message-ID: <E1G339V-0004z8-00@gondolin.me.apana.org.au>
References: <20060718114430.73985431@localhost.localdomain>
Cc: akpm@osdl.org, zach@vmware.com, jeremy@goop.org,
	xen-devel@lists.xensource.com, ian.pratt@xensource.com,
	netdev@vger.kernel.org, rusty@rustcorp.com.au,
	linux-kernel@vger.kernel.org, ak@suse.de, chrisw@sous-sol.org,
	virtualization@lists.osdl.org, Christian.Limpach@cl.cam.ac.uk
Return-path: <xen-devel-bounces@lists.xensource.com>
To: shemminger@osdl.org (Stephen Hemminger)
In-Reply-To: <20060718114430.73985431@localhost.localdomain>
List-Unsubscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=unsubscribe>
List-Post: <mailto:xen-devel@lists.xensource.com>
List-Help: <mailto:xen-devel-request@lists.xensource.com?subject=help>
List-Subscribe: <http://lists.xensource.com/cgi-bin/mailman/listinfo/xen-devel>,
	<mailto:xen-devel-request@lists.xensource.com?subject=subscribe>
Sender: xen-devel-bounces@lists.xensource.com
Errors-To: xen-devel-bounces@lists.xensource.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> wrote:
> 
>> diff -r eadc12b20f35 drivers/xen/netfront/netfront.c
>> --- /dev/null Thu Jan 01 00:00:00 1970 +0000
>> +++ b/drivers/xen/netfront/netfront.c Fri Jun 09 15:03:12 2006 -0400
>> @@ -0,0 +1,1584 @@
> 
>> +static inline void init_skb_shinfo(struct sk_buff *skb)
>> +{
>> +     atomic_set(&(skb_shinfo(skb)->dataref), 1);
>> +     skb_shinfo(skb)->nr_frags = 0;
>> +     skb_shinfo(skb)->frag_list = NULL;
>> +}
> 
> Shouldn't this move to skbuff.h?

If and when my dom0=>domU GSO patches are applied, this will simply
disappear.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
