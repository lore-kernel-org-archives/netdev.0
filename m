From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: [PATCH RFX]: napi_struct V3
Date: Tue, 24 Jul 2007 16:21:43 +1000
Message-ID: <1185258104.1803.223.camel@localhost.localdomain>
References: <20070723.210748.63127793.davem@davemloft.net>
	 <1185252439.1803.174.camel@localhost.localdomain>
	 <20070723.224707.30179585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, shemminger@linux-foundation.org,
	jgarzik@pobox.com, hadi@cyberus.ca
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ozlabs.org ([203.10.76.45]:38186 "EHLO ozlabs.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754959AbXGXGWH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Jul 2007 02:22:07 -0400
In-Reply-To: <20070723.224707.30179585.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2007-07-23 at 22:47 -0700, David Miller wrote:
> I don't think it's wise to implement this over and over again in each
> driver, since we already know at least a handfull of drivers will use
> this.

Yep.  Alternative is a napi_struct_with_restart, but I don't think it's
worth the few-byte savings per queue.

> Any objections?

On the contrary, this looks good.

Thanks!
Rusty.

