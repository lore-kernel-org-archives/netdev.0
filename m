From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ipv6: cleanup: remove unneeded null check
Date: Fri, 30 Apr 2010 16:42:52 -0700 (PDT)
Message-ID: <20100430.164252.170100570.davem@davemloft.net>
References: <20100429143034.GI29093@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com, sri@us.ibm.com,
	herbert@gondor.apana.org.au, emils.tantilov@gmail.com,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45771
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759973Ab0D3Xmq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Apr 2010 19:42:46 -0400
In-Reply-To: <20100429143034.GI29093@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 29 Apr 2010 16:30:35 +0200

> We dereference "sk" unconditionally elsewhere in the function.  
> 
> This was left over from:  b30bd282 "ip6_xmit: remove unnecessary NULL
> ptr check".  According to that commit message, "the sk argument to 
> ip6_xmit is never NULL nowadays since the skb->priority assigment 
> expects a valid socket."
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied, thanks Dan.
