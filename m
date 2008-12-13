From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 8/9][v2] mISDN: timerdev: use __user for mISDN_read's
 buffer argument
Date: Fri, 12 Dec 2008 21:19:26 -0800 (PST)
Message-ID: <20081212.211926.239388789.davem@davemloft.net>
References: <49419a3f.0710660a.4800.7087@mx.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kkeil@suse.de,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: hannes@hanneseder.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56298
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752081AbYLMFTZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Dec 2008 00:19:25 -0500
In-Reply-To: <49419a3f.0710660a.4800.7087@mx.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Hannes Eder <hannes@hanneseder.net>
Date: Thu, 11 Dec 2008 22:36:00 +0100

> Fix this warning:
> 
>   drivers/isdn/mISDN/timerdev.c:264:11: warning: incorrect type in initializer (incompatible argument 2 (different address spaces))
>   drivers/isdn/mISDN/timerdev.c:264:11:    expected int ( *read )( ... )
>   drivers/isdn/mISDN/timerdev.c:264:11:    got int ( static [toplevel] *<noident> )( ... )
> 
> Signed-off-by: Hannes Eder <hannes@hanneseder.net>
> Acked-by: Karsten Keil <kkeil@suse.de>

Applied.
