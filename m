From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [IPV6] RAW: Add checksum default defines for MH.
Date: Wed, 24 Jan 2007 16:05:41 +0900 (JST)
Message-ID: <20070124.160541.07096404.yoshfuji@linux-ipv6.org>
References: <20070123.221918.35467190.davem@davemloft.net>
	<E1H9c3T-0005HA-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, nakam@linux-ipv6.org, takamiya@po.ntts.co.jp,
	netdev@vger.kernel.org, yoshfuji@linux-ipv6.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:46586 "EHLO
	yue.st-paulia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933093AbXAXHEa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Jan 2007 02:04:30 -0500
In-Reply-To: <E1H9c3T-0005HA-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <E1H9c3T-0005HA-00@gondolin.me.apana.org.au> (at Wed, 24 Jan 2007 17:56:23 +1100), Herbert Xu <herbert@gondor.apana.org.au> says:

> David Miller <davem@davemloft.net> wrote:
> >
> > Did a complete agreement occur that this patch is ok?
> 
> My only concern is that we're putting an arbitrary list of
> protocols in the generic raw.c.  What's the justification
> for including these protocols in particular but not others?
> 
> Is there any reason why the application can't just use the
> existing IPV6_CHECKSUM socket option to set the same fields?

Yes, it can.

The only reason they (not myself :-)) want to put this in is
because the RFC says that MIP6 implementation MUST compute
checksum by default when it passes the MH to userspace.  On
the other hand, it also states that user space application SHOULD
set IPV6_CHECKSUM to 4.

--yoshfuji

