From: David Miller <davem@davemloft.net>
Subject: Re: NETLINK sockets dont honor SO_RCVLOWAT?
Date: Wed, 18 Nov 2009 10:44:34 -0800 (PST)
Message-ID: <20091118.104434.185425439.davem@davemloft.net>
References: <D67825C5985D0647BE40A5F5B0B70D1106E9C568F1@HQ-EXCH-7.corp.brocade.com>
	<20091118.102434.160976750.davem@davemloft.net>
	<D67825C5985D0647BE40A5F5B0B70D1106E9C568FE@HQ-EXCH-7.corp.brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jharan@Brocade.COM
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47018
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755671AbZKRSoR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Nov 2009 13:44:17 -0500
In-Reply-To: <D67825C5985D0647BE40A5F5B0B70D1106E9C568FE@HQ-EXCH-7.corp.brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Haran <jharan@Brocade.COM>
Date: Wed, 18 Nov 2009 10:41:06 -0800

> The operative term is "shall". The RFCs define "shall" to be
> required behavior. I realize the RFCs do not dictate how Linux
> works, but even the common English language usage of the word
> "shall" conveys this meaning.

The low water mark can be seen as a hint, therefore we can
apply the term "support" loosely here.

And the errors are advisory, just like things like -EFAULT.

Look, I'm not going to add a feature flag or some callback just to
handle this.

You have to know what kind of protocol you are working with, and
therefore which socket options make any sense for it.

