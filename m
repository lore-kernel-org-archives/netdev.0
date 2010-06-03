From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn/kcapi: return -EFAULT on copy_from_user errors
Date: Thu, 03 Jun 2010 03:29:16 -0700 (PDT)
Message-ID: <20100603.032916.267394338.davem@davemloft.net>
References: <20100603095613.GP5483@bicker>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: isdn@linux-pingi.de, jan.kiszka@web.de, tilman@imap.cc,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: error27@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50285
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933713Ab0FCK3G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:29:06 -0400
In-Reply-To: <20100603095613.GP5483@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Dan Carpenter <error27@gmail.com>
Date: Thu, 3 Jun 2010 11:56:13 +0200

> copy_from_user() returns the number of bytes remaining but we should
> return -EFAULT here.  The error code gets returned to the user.  Both 
> old_capi_manufacturer() and capi20_manufacturer() had other places
> that already returned -EFAULT so this won't break anything.
> 
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Applied.
