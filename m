From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Avoid pointer in netlink_run_queue
Date: Sun, 16 Sep 2007 16:31:14 -0700 (PDT)
Message-ID: <20070916.163114.21928669.davem@davemloft.net>
References: <20070831120930.GA29914@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35090
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751829AbXIPXbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 19:31:14 -0400
In-Reply-To: <20070831120930.GA29914@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Fri, 31 Aug 2007 20:09:30 +0800

> Hi Dave:
> 
> [NETLINK]: Avoid pointer in netlink_run_queue
> 
> I was looking at Patrick's fix to inet_diag and it occured
> to me that we're using a pointer argument to return values
> unnecessarily in netlink_run_queue.  Changing it to return
> the value will allow the compiler to generate better code
> since the value won't have to be memory-backed.
> 
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Applied to net-2.6.24, thanks Herbert.
