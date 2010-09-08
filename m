From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: remove address space warnings in net/socket.c
Date: Wed, 08 Sep 2010 13:46:32 -0700 (PDT)
Message-ID: <20100908.134632.35051274.davem@davemloft.net>
References: <1283867700-24132-1-git-send-email-namhyung@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: namhyung@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44993
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751557Ab0IHUqO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Sep 2010 16:46:14 -0400
In-Reply-To: <1283867700-24132-1-git-send-email-namhyung@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Namhyung Kim <namhyung@gmail.com>
Date: Tue,  7 Sep 2010 22:55:00 +0900

> Casts __kernel to __user pointer require __force markup, so add it. Also
> sock_get/setsockopt() takes @optval and/or @optlen arguments as user pointers
> but were taking kernel pointers, use new variables 'uoptval' and/or 'uoptlen'
> to fix it. These remove following warnings from sparse:
...
> Signed-off-by: Namhyung Kim <namhyung@gmail.com>

Applied to net-next-2.6, thank you.
