From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use scnprintf() to avoid potential buffer overflow
Date: Thu, 26 Aug 2010 14:12:31 -0700 (PDT)
Message-ID: <20100826.141231.35022316.davem@davemloft.net>
References: <1282692778-2945-1-git-send-email-xiaosuo@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: xiaosuo@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44457
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754087Ab0HZVMP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Aug 2010 17:12:15 -0400
In-Reply-To: <1282692778-2945-1-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Changli Gao <xiaosuo@gmail.com>
Date: Wed, 25 Aug 2010 07:32:58 +0800

> strlcpy() returns the total length of the string they tried to create, so
> we should not use its return value without any check. scnprintf() returns
> the number of characters written into @buf not including the trailing '\0',
> so use it instead here.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Applied.
