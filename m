From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: "ip neigh show" not showing arp cache entries?
Date: Tue, 18 Dec 2007 11:33:29 +0800
Message-ID: <E1J4TCz-0005L8-00@gondolin.me.apana.org.au>
References: <476696A5.1010101@nortel.com>
Cc: yoshfuji@linux-ipv6.org, dada1@cosmosbay.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: cfriesen@nortel.com (Chris Friesen)
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1760676AbXLRDdu@vger.kernel.org>
In-Reply-To: <476696A5.1010101@nortel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Chris Friesen <cfriesen@nortel.com> wrote:
>
> However, if I specifically try to print out one of the missing entries, 
> it shows up:
> 
> root@typhoon-base-unit0:/root> /tmp/ip neigh show 192.168.24.81
> 192.168.24.81 dev bond2 lladdr 00:01:af:14:e9:8a REACHABLE

What about

	ip -4 neigh show

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
