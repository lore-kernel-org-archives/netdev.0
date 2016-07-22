From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] packet: propagate sock_cmsg_send() error
Date: Fri, 22 Jul 2016 01:42:21 -0400 (EDT)
Message-ID: <20160722.014221.677129165643541278.davem@davemloft.net>
References: <1469052078-31269-1-git-send-email-soheil.kdev@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, willemb@google.com, soheil@google.com
To: soheil.kdev@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:51954 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751378AbcGVFm0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 Jul 2016 01:42:26 -0400
In-Reply-To: <1469052078-31269-1-git-send-email-soheil.kdev@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Soheil Hassas Yeganeh <soheil.kdev@gmail.com>
Date: Wed, 20 Jul 2016 18:01:18 -0400

> From: Soheil Hassas Yeganeh <soheil@google.com>
> 
> sock_cmsg_send() can return different error codes and not only
> -EINVAL, and we should properly propagate them.
> 
> Fixes: c14ac9451c34 ("sock: enable timestamping using control messages")
> Signed-off-by: Soheil Hassas Yeganeh <soheil@google.com>
> Cc: Willem de Bruijn <willemb@google.com>

Applied, thanks.
