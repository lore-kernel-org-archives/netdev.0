From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net/socket: fix type in assignment and trim long
 line
Date: Mon, 24 Jul 2017 14:17:32 -0700 (PDT)
Message-ID: <20170724.141732.484131849675542497.davem@davemloft.net>
References: <5226dfcbd13df441445da0caccae5867fdc80c4c.1500655551.git.pabeni@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, viro@zeniv.linux.org.uk
To: pabeni@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:43226 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932826AbdGXVRd (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 24 Jul 2017 17:17:33 -0400
In-Reply-To: <5226dfcbd13df441445da0caccae5867fdc80c4c.1500655551.git.pabeni@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paolo Abeni <pabeni@redhat.com>
Date: Fri, 21 Jul 2017 18:49:45 +0200

> The commit ffb07550c76f ("copy_msghdr_from_user(): get rid of
> field-by-field copyin") introduce a new sparse warning:
> 
> net/socket.c:1919:27: warning: incorrect type in assignment (different address spaces)
> net/socket.c:1919:27:    expected void *msg_control
> net/socket.c:1919:27:    got void [noderef] <asn:1>*[addressable] msg_control
> 
> and a line above 80 chars, let's fix them
> 
> Fixes: ffb07550c76f ("copy_msghdr_from_user(): get rid of field-by-field copyin")
> Signed-off-by: Paolo Abeni <pabeni@redhat.com>

Applied, thanks.
