From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Regarding offloading IPv6 addrconf and ndisc
Date: Tue, 1 Aug 2006 11:30:33 +1000
Message-ID: <20060801013033.GA1280@gondor.apana.org.au>
References: <E1G6Fic-0005py-00@gondolin.me.apana.org.au> <20060727.183415.104032934.davem@davemloft.net> <200608010231.58339.ak@suse.de> <20060731.174641.99457765.davem@davemloft.net> <ada7j1t700x.fsf@cisco.com> <1154395467.5170.31.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Roland Dreier <rdreier@cisco.com>,
	David Miller <davem@davemloft.net>, ak@suse.de,
	kazunori@miyazawa.org, yoshfuji@linux-ipv6.org,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:36615 "EHLO
	arnor.apana.org.au") by vger.kernel.org with ESMTP id S1030385AbWHABbM
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 21:31:12 -0400
To: Jamal Hadi Salim <hadi@cyberus.ca>
Content-Disposition: inline
In-Reply-To: <1154395467.5170.31.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 31, 2006 at 09:24:27PM -0400, Jamal Hadi Salim wrote:
>  
> In regards to reliability: The thing that really fscks people using
> daemons from what i have seen is the oom killer policies and the lack of
> correlation by apps. I just watched quagga die horribly on a 256M
> machine on friday once we hit around 100K routes and a lot of route
> cache hits. So apps like that may need a total rewrite. I am not looking
> forward to trying to get racoon to do 50K SAs and 100K SPDs on the same
> machine ;->

You can now disable the OOM killer on a per-process basis by

echo -17 > /proc/<pid>/oom_adj

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
