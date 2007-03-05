From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] NET : convert network timestamps to ktime_t
Date: Mon, 05 Mar 2007 00:00:34 -0800 (PST)
Message-ID: <20070305.000034.74747229.davem@davemloft.net>
References: <20070304.161924.55508971.davem@davemloft.net>
	<45EBBF21.1000209@cosmosbay.com>
	<45EBC953.30905@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, linux.kernel@free.fr,
	netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46648
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S932152AbXCEIAg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Mar 2007 03:00:36 -0500
In-Reply-To: <45EBC953.30905@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Mon, 05 Mar 2007 08:40:03 +0100

> Here is the second version of this patch, including missing bits spoted by 
> Stephen. This is against net-2.6.22

Applied, thanks a lot.

> Note : this patch includes a bug correction in compat_sock_get_timestamp()
> where a "err = 0;" was missing (so this syscall returned -ENOENT instead of
> 0)

Grrr, good spotting.  Eric can you send me a version of just this bug
fix against 2.6.21?  I'll push that to Linus and 2.6.x-stable.

I guess most applications don't even bother to check the getsockopt()
return value. :-)

Thanks a lot!
