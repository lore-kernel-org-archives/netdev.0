From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [BUG] sky2 broken for Yukon PCI-E Gigabit Ethernet Controller 11ab:4362 (rev 19)
Date: Wed, 25 Jan 2006 07:32:36 +1100
Message-ID: <E1F1UqC-0002XE-00@gondolin.me.apana.org.au>
References: <43D5F6DD.70702@t-online.de>
Cc: shemminger@osdl.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965008AbWAXUdE@vger.kernel.org>
To: Knut_Petersen@t-online.de (Knut Petersen)
In-Reply-To: <43D5F6DD.70702@t-online.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Knut Petersen <Knut_Petersen@t-online.de> wrote:
>
> "ethtool -K eth0 rx off" does cure my problem with sky2.
> 
> Anybody is invited to send patches as the problem is 100% reproducible here.

Does the problem go away if you disable conntrack by unloading its module?

Please try to capture the offending ICMP packet with tcpdump and show us
what it looks like.

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
