From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/atm: sk_err_soft must be positive
Date: Mon, 23 May 2016 13:51:36 -0700 (PDT)
Message-ID: <20160523.135136.1639061056251132017.davem@davemloft.net>
References: <1463618533-7098-1-git-send-email-stefanha@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: stefanha@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50157 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750888AbcEWUvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 May 2016 16:51:38 -0400
In-Reply-To: <1463618533-7098-1-git-send-email-stefanha@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stefan Hajnoczi <stefanha@redhat.com>
Date: Wed, 18 May 2016 17:42:13 -0700

> The sk_err and sk_err_soft fields are positive errno values and
> userspace applications rely on this when using getsockopt(SO_ERROR).
> 
> ATM code places an -errno into sk_err_soft in sigd_send() and returns it
> from svc_addparty()/svc_dropparty().
> 
> Although I am not familiar with ATM code I came to this conclusion
> because:
 ...
> This patch ensures that sk_err_soft is always a positive errno.
> 
> Signed-off-by: Stefan Hajnoczi <stefanha@redhat.com>
> ---
> This patch is untested and potentially affects the getsockopt(SO_ERROR) ABI for
> a specific case in ATM.  I leave it to the maintainer to decide whether this
> inconsistency should be fixed or not.

This looks fine, applied, thanks.
