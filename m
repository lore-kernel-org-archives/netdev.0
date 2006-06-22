From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?=
	<yoshfuji@linux-ipv6.org>
Subject: Re: [0/5] GSO: Generic Segmentation Offload
Date: Thu, 22 Jun 2006 23:28:01 +0900 (JST)
Message-ID: <20060622.232801.02912673.yoshfuji@linux-ipv6.org>
References: <20060622081211.GA22505@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	yoshfuji@linux-ipv6.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from yue.linux-ipv6.org ([203.178.140.15]:18440 "EHLO
	yue.st-paulia.net") by vger.kernel.org with ESMTP id S1030289AbWFVO1I
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 22 Jun 2006 10:27:08 -0400
To: herbert@gondor.apana.org.au
In-Reply-To: <20060622081211.GA22505@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

Yes, I genrally like this idea.

In article <20060622081211.GA22505@gondor.apana.org.au> (at Thu, 22 Jun 2006 18:12:11 +1000), Herbert Xu <herbert@gondor.apana.org.au> says:

> GSO like TSO is only effective if the MTU is significantly less than the
> maximum value of 64K.  So only the case where the MTU was set to 1500 is
> of interest.  There we can see that the throughput improved by 17.5%
> (3061.05Mb/s => 3598.17Mb/s).  The actual saving in transmission cost is
> in fact a lot more than that as the majority of the time here is spent on
> the RX side which still has to deal with 1500-byte packets.

Can you measure some with other sizes,
e.g. 4kByte, 8kByte, 9000Byte?

--yoshfuji
