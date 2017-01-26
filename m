From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] [net-next] ISDN: eicon: reduce stack size of sig_ind
 function
Date: Thu, 26 Jan 2017 14:00:33 -0500 (EST)
Message-ID: <20170126.140033.1039326394984007010.davem@davemloft.net>
References: <20170125221607.1102271-1-arnd@arndb.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mac@melware.de, isdn@linux-pingi.de, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: arnd@arndb.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39252 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752241AbdAZTMw (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Jan 2017 14:12:52 -0500
In-Reply-To: <20170125221607.1102271-1-arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Arnd Bergmann <arnd@arndb.de>
Date: Wed, 25 Jan 2017 23:15:53 +0100

> I noticed that this function uses a lot of kernel stack when the
> "latent entropy" plugin is enabled:
> 
> drivers/isdn/hardware/eicon/message.c: In function 'sig_ind':
> drivers/isdn/hardware/eicon/message.c:6113:1: error: the frame size of 1168 bytes is larger than 1152 bytes [-Werror=frame-larger-than=]
> 
> We currently don't warn about this, as we raise the warning limit
> to 2048 bytes in mainline, but I'd like to lower that limit again
> in the future, and this function can easily be changed to be more
> efficient and avoid that warning, by making some of its local
> variables 'const'.
> 
> Signed-off-by: Arnd Bergmann <arnd@arndb.de>

Applied, thanks Arnd.
