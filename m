From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/3 v2] ipv6: cancel to setting local_df
 in ip6_xmit()
Date: Thu, 15 Apr 2010 23:37:27 -0700 (PDT)
Message-ID: <20100415.233727.02312488.davem@davemloft.net>
References: <4BC7CDD2.5020004@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, emils.tantilov@gmail.com,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: shanwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51935
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754568Ab0DPGhY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Apr 2010 02:37:24 -0400
In-Reply-To: <4BC7CDD2.5020004@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shan Wei <shanwei@cn.fujitsu.com>
Date: Fri, 16 Apr 2010 10:39:14 +0800

> commit f88037(sctp: Drop ipfargok in sctp_xmit function)
> has droped ipfragok and set local_df value properly.
> 
> So the change of commit 77e2f1(ipv6: Fix ip6_xmit to 
> send fragments if ipfragok is true) is not needed. 
> So the patch remove them.
> 
> Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>

Applied.
