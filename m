From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: fix information leak
Date: Thu, 05 Aug 2010 13:21:55 -0700 (PDT)
Message-ID: <20100805.132155.220076581.davem@davemloft.net>
References: <20100805093806.GF9031@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47422
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S934048Ab0HEUVh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Aug 2010 16:21:37 -0400
In-Reply-To: <20100805093806.GF9031@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 5 Aug 2010 11:38:06 +0200

> The main motivation of this patch changing strcpy() to strlcpy().  
> We strcpy() to copy a 48 byte buffers into a 49 byte buffers.  So at
> best the last byte has leaked information, or maybe there is an
> overflow?  Anyway, this patch closes the information leaks by zeroing
> the memory and the calls to strlcpy() prevent overflows. 
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
