From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH] ip multicast route bug fix
Date: Tue, 25 Jul 2006 20:48:07 +0400
Message-ID: <20060725164807.GA18292@ms2.inr.ac.ru>
References: <20060719145716.4cb9e7e2@localhost.localdomain> <20060725162001.GA15058@ms2.inr.ac.ru> <20060725085528.38b86319@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:57569 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932449AbWGYQsV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2006 12:48:21 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060725085528.38b86319@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> checking tools because the skb lifetime depends on the return value.
> Wouldn't it be better to have a consistent interface (skb always freed),
> and clone the skb if needed for deferred processing?

But skb is not always freed in any case.
Normally it is submitted to netlink_unicast(). It is freed only in error case.
So, following this logic should not you clone skb to feed to netlink_unicast()?

Alexey

