From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] uapi: fix linux/if.h userspace compilation errors
Date: Tue, 21 Feb 2017 12:10:22 -0500 (EST)
Message-ID: <20170221.121022.676021611021776681.davem@davemloft.net>
References: <20170220115841.GA6846@altlinux.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: ldv@altlinux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55146 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753916AbdBURK1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 12:10:27 -0500
In-Reply-To: <20170220115841.GA6846@altlinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Dmitry V. Levin" <ldv@altlinux.org>
Date: Mon, 20 Feb 2017 14:58:41 +0300

> Include <sys/socket.h> (guarded by ifndef __KERNEL__) to fix
> the following linux/if.h userspace compilation errors:

Wouldn't it be so much better to do this in include/uapi/linux/socket.h?

I mean, look at the comment right by the change you are making:

> @@ -24,6 +24,10 @@
>  #include <linux/socket.h>		/* for "struct sockaddr" et al	*/
                                           ^^^^^^^^^^^^^^^^^^^^^^^

Anyone including linux/socket.h is trying to obtain that type.
