From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 2/9] gue: Support for Generic UDP
 Encapsulation RX path
Date: Thu, 17 Jul 2014 14:50:56 -0700 (PDT)
Message-ID: <20140717.145056.746494607843911465.davem@davemloft.net>
References: <alpine.DEB.2.02.1407162058200.2128@tomh.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40944 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752856AbaGQVu5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jul 2014 17:50:57 -0400
In-Reply-To: <alpine.DEB.2.02.1407162058200.2128@tomh.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Wed, 16 Jul 2014 21:14:30 -0700 (PDT)

> +static inline struct gue *gue_from_sock(struct sock *sk)
> +{
> +	return (struct gue *)sk->sk_user_data;
> +}

Casting a void pointer like this is never appropriate.
