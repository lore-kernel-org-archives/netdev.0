From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH][SCTP] Re: lockdep: inconsistent lock state ipv6_add_addr/sctp_v6_copy_addrlist (2.6.21-rc1)
Date: Thu, 8 Mar 2007 22:02:30 +1100
Message-ID: <20070308110230.GA9175@gondor.apana.org.au>
References: <20070308074751.GA2085@ff.dom.local> <E1HPGMB-0002AG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: simon@arlott.org, linux-kernel@vger.kernel.org, sri@us.ibm.com,
	netdev@vger.kernel.org, lksctp-developers@lists.sourceforge.net
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751281AbXCHLDP@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E1HPGMB-0002AG-00@gondolin.me.apana.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Mar 08, 2007 at 10:00:23PM +1100, Herbert Xu wrote:
> 
> Who's calling ipv6_add_addr from softirq context? That's got to be
> wrong because ipv6_add_addr requires the RTNL.

Nevermind, I was thinking of ipv6_add_dev.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
