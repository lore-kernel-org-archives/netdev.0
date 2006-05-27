From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [1/4] [IPSEC] xfrm: Undo afinfo lock proliferation
Date: Sat, 27 May 2006 21:05:19 +0900 (JST)
Message-ID: <20060527.210519.119151107.yoshfuji@linux-ipv6.org>
References: <20060527113236.GA4203@gondor.apana.org.au>
	<20060527113345.GA4737@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:42247 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1751484AbWE0MEu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 27 May 2006 08:04:50 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060527113345.GA4737@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In article <20060527113345.GA4737@gondor.apana.org.au> (at Sat, 27 May 2006 21:33:45 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> As far as I can gather it's an attempt to guard against the removal of
> the corresponding modules.  Since neither module can be unloaded at all
> we can leave it to whoever fixes up IPv6 unloading :)

I disagree. Please do not add another mess.

--yoshfuji
