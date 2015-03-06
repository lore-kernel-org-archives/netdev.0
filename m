From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] fib: make netdev_switch_fib_ipv4_abort in
 header file static inline
Date: Fri, 06 Mar 2015 15:44:50 -0500 (EST)
Message-ID: <20150306.154450.371792927238444330.davem@davemloft.net>
References: <1425660268-23344-1-git-send-email-willemb@google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sfeldma@gmail.com,
	alexander.duyck@gmail.com
To: willemb@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56087 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755288AbbCFUox (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2015 15:44:53 -0500
In-Reply-To: <1425660268-23344-1-git-send-email-willemb@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Willem de Bruijn <willemb@google.com>
Date: Fri,  6 Mar 2015 11:44:28 -0500

> From: Willem de Bruijn <willemb@google.com>
> 
> When building without CONFIG_NET_SWITCHDEV,
> netdev_switch_fib_ipv4_abort is defined in the header file. It must
> be static inline to avoid build failure at link time.
> 
> Fixes: 8e05fd7166c6 ("fib: hook IPv4 fib for hardware offload")
> 
> Signed-off-by: Willem de Bruijn <willemb@google.com>

Applied, thanks Willem.
