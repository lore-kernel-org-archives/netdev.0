From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Thu, 29 Nov 2007 20:21:37 +1100
Message-ID: <20071129092136.GB30066@gondor.apana.org.au>
References: <20071119.142313.63549156.davem@davemloft.net> <20071120002945.91fafb2b.billfink@mindspring.com> <20071120140518.GA1502@one.firstfloor.org> <20071120.173928.53148729.davem@davemloft.net> <474E707A.3080106@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, andi@firstfloor.org,
	billfink@mindspring.com, netdev@vger.kernel.org,
	gerrit@erg.abdn.ac.uk, bfields@fieldses.org, neilb@suse.de,
	okir@monad.swb.de
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:1185 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755516AbXK2JWp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Nov 2007 04:22:45 -0500
Content-Disposition: inline
In-Reply-To: <474E707A.3080106@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 29, 2007 at 03:55:38PM +0800, Wang Chen wrote:
> 
> I tested nfsv3 & nfsv4. It seems that nfs calls recvmsg() like
> following:nfsd()->svc_recv()->svc_udp_recvfrom()->udp_recvmsg().
> So, I think putting the udpInDatagrams increment in udp_recvmsg()
> is enough.
> 
> FYI:
> http://www.mail-archive.com/netdev@vger.kernel.org/msg13817.html

Excellent.  They now do a recvmsg first with no buffer to get
meta-information, which just happens to increment the counters.

Could you please resubmit the patch then?

Thanks,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
