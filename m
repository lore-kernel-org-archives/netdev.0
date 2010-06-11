From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net8139: fix a race at the end of NAPI
Date: Thu, 10 Jun 2010 23:17:01 -0700 (PDT)
Message-ID: <20100610.231701.68142438.davem@davemloft.net>
References: <1275979719.1927.4.camel@myhost>
	<1275981202.1927.6.camel@myhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: zhangtianfei@leadcoretech.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56134
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754976Ab0FKGQu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Jun 2010 02:16:50 -0400
In-Reply-To: <1275981202.1927.6.camel@myhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Figo.zhang" <zhangtianfei@leadcoretech.com>
Date: Tue, 08 Jun 2010 15:13:22 +0800

>  
> fix a race at the end of NAPI complete processing, it had
> better do __napi_complete() first before re-enable interrupt.
> 
> Signed-off-by:Figo.zhang <figo1802@gmail.com>

Applied, thank you.
