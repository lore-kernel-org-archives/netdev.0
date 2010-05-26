From: David Miller <davem@davemloft.net>
Subject: Re: [patch] ipmr: off by one in __ipmr_fill_mroute()
Date: Wed, 26 May 2010 00:39:16 -0700 (PDT)
Message-ID: <20100526.003916.39169713.davem@davemloft.net>
References: <20100522175357.GF22515@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46801
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932105Ab0EZHjG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 May 2010 03:39:06 -0400
In-Reply-To: <20100522175357.GF22515@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 22 May 2010 19:54:48 +0200

> This fixes a smatch warning:
> 	net/ipv4/ipmr.c +1917 __ipmr_fill_mroute(12) error: buffer overflow
> 	'(mrt)->vif_table' 32 <= 32
> 
> The ipv6 version had the same issue.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Introduced by commit "7438189b".

Applied, thanks Dan.
