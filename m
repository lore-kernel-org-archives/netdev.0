From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Memory leak in 2.6.11-rc1?
Date: Mon, 31 Jan 2005 15:11:32 +1100
Message-ID: <E1CvSuS-00056x-00@gondolin.me.apana.org.au>
References: <41FD2043.3070303@trash.net>
Cc: rmk+lkml@arm.linux.org.uk, davem@davemloft.net,
	Robert.Olsson@data.slu.se, akpm@osdl.org, torvalds@osdl.org,
	alexn@dsv.su.se, kas@fi.muni.cz, linux-kernel@vger.kernel.org,
	netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261912AbVAaEPn@vger.kernel.org>
To: kaber@trash.net (Patrick McHardy)
In-Reply-To: <41FD2043.3070303@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> wrote:
> 
> Ok, final decision: you are right :) conntrack also defragments locally
> generated packets before they hit ip_fragment. In this case the fragments
> have skb->dst set.

Well caught.  The same thing is needed for IPv6, right?
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
