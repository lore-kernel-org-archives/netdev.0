From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 2/3 v2] net: replace ipfragok with
 skb->local_df
Date: Thu, 15 Apr 2010 23:37:33 -0700 (PDT)
Message-ID: <20100415.233733.35006639.davem@davemloft.net>
References: <4BC7CEBC.70200@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, yinghai.lu@oracle.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, netdev@vger.kernel.org,
	dccp@vger.kernel.org, linux-sctp@vger.kernel.org,
	jchapman@katalix.com, mostrows@speakeasy.net
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51949
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754540Ab0DPGha (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 02:37:30 -0400
In-Reply-To: <4BC7CEBC.70200@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 16 Apr 2010 10:43:08 +0800

> As Herbert Xu said: we should be able to simply replace ipfragok
> with skb->local_df. commit f88037(sctp: Drop ipfargok in sctp_xmit function)
> has droped ipfragok and set local_df value properly.
> 
> The patch kills the ipfragok parameter of .queue_xmit().
> 
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
