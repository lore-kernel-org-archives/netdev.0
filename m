From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/3] fec: Do not use NULL pointer to indicate
 error
Date: Tue, 02 Sep 2014 13:48:49 -0700 (PDT)
Message-ID: <20140902.134849.506263512436464245.davem@davemloft.net>
References: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@arm.linux.org.uk, B38611@freescale.com,
	netdev@vger.kernel.org, fabio.estevam@freescale.com
To: festevam@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:58417 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755194AbaIBUsu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Sep 2014 16:48:50 -0400
In-Reply-To: <1409620375-20284-1-git-send-email-festevam@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Fabio Estevam <festevam@gmail.com>
Date: Mon,  1 Sep 2014 22:12:52 -0300

> Using IS_ERR() to indicate error can simplify the code a bit, so let's use
> it when appropriate.

I would rather you not do this.

Generally speaking we should not leave pointer error values in
structure pointers.

It's just asking for someone to later accidently kfree or
release the "object" because pointer errors evaluate to
non-NULL.
