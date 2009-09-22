From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] lib/vsprintf.c: Avoid possible unaligned accesses in
 %pI6c
Date: Tue, 22 Sep 2009 14:17:59 -0700 (PDT)
Message-ID: <20090922.141759.225859486.davem@davemloft.net>
References: <1253315046.2543.475.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, me@jayr.de
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:52085
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752561AbZIVVRk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Sep 2009 17:17:40 -0400
In-Reply-To: <1253315046.2543.475.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Joe Perches <joe@perches.com>
Date: Fri, 18 Sep 2009 16:04:06 -0700

> Jens Rosenboom noticed that a possibly unaligned const char*
> is cast to a const struct in6_addr *.
> 
> Avoid this at the cost of a struct in6_addr copy on the stack.
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied, thanks.
