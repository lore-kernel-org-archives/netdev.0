From: David Miller <davem@davemloft.net>
Subject: Re: [patch] isdn/kcapi: return -EFAULT on copy_from_user errors
Date: Thu, 03 Jun 2010 03:29:08 -0700 (PDT)
Message-ID: <20100603.032908.38313177.davem@davemloft.net>
References: <20100603095613.GP5483@bicker>
	<4C078362.1080005@web.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: error27@gmail.com, isdn@linux-pingi.de, tilman@imap.cc,
	netdev@vger.kernel.org, kernel-janitors@vger.kernel.org
To: jan.kiszka@web.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50275
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S933793Ab0FCK26 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 06:28:58 -0400
In-Reply-To: <4C078362.1080005@web.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jan Kiszka <jan.kiszka@web.de>
Date: Thu, 03 Jun 2010 12:26:42 +0200

> No need to assign retval anymore, it is overwritten in all non-error cases.

I'm still going to apply this fix as-is since it's easier to validate
and provably won't introduce new compiler warnings.
