From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ipv4/arp.c: Use the exported hex_asc from
 lib/hexdump.c instead
Date: Tue, 20 May 2008 15:36:11 -0700 (PDT)
Message-ID: <20080520.153611.204837174.davem@davemloft.net>
References: <1211135864-8235-1-git-send-email-crquan@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: crquan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56203
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S934811AbYETWgQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2008 18:36:16 -0400
In-Reply-To: <1211135864-8235-1-git-send-email-crquan@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Cheng <crquan@gmail.com>
Date: Mon, 19 May 2008 02:37:44 +0800

> Here the local hexbuf is a duplicate of global const char hex_asc from
> lib/hexdump.c, except the hex letters' cases:
> 
> const char hexbuf[] = "0123456789ABCDEF";
> 
> const char hex_asc[] = "0123456789abcdef";
> 
> and here to print HW addresses, the hex cases are not significant.
> 
> Signed-off-by: Denis Cheng <crquan@gmail.com>

Applied, thanks.
