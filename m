From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn: potential buffer overflows
Date: Mon, 06 Sep 2010 18:30:25 -0700 (PDT)
Message-ID: <20100906.183025.02291340.davem@davemloft.net>
References: <20100904183806.GO5437@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50298
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755916Ab0IGBaI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Sep 2010 21:30:08 -0400
In-Reply-To: <20100904183806.GO5437@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Sat, 4 Sep 2010 20:38:59 +0200

> cs->ics.parm.setup.phone is a 32 character array.  In each of these
> cases we're copying from a 35 character array into a 32 character array
> so we should use strlcpy() instead of strcpy().
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
