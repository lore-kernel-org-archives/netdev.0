From: David Miller <davem@davemloft.net>
Subject: Re: Influencing triggering of xfrm acquire messages?
Date: Thu, 11 Aug 2011 07:36:45 -0700 (PDT)
Message-ID: <20110811.073645.142128983331087817.davem@davemloft.net>
References: <CAGsyNe2oAkT+idnC-fuOoULTdEubbL8CabLesacjp=2tPiWVmA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: david.martin.mailbox@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44927 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751329Ab1HKOgr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Aug 2011 10:36:47 -0400
In-Reply-To: <CAGsyNe2oAkT+idnC-fuOoULTdEubbL8CabLesacjp=2tPiWVmA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Martin <david.martin.mailbox@googlemail.com>
Date: Thu, 11 Aug 2011 16:21:07 +0200

> As long as it exists no additional acquire will be triggered which is a problem,
> for example when shortly after an exchange the daemon is restarted and needs to
> start another exchange with the same peer host.
> 
> Is this state supposed to be set up? Is it supposed to be removed automatically
> once we set up our own SA? Is there a way to remove it manually to
> trigger another acquire? Any input is welcome, thanks a lot in advance.

The usage model is that the IPSEC daemon, like a routing daemon, manages
all IPSEC state.  And therefore it flushes all IPSEC state when it starts
up.

If you want the acquire messages, you need to flush the entries for which
you want the acquire to trigger when you startup.

