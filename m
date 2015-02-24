From: David Miller <davem@davemloft.net>
Subject: Re: Setting RPS affinities from network driver
Date: Mon, 23 Feb 2015 22:14:03 -0500 (EST)
Message-ID: <20150223.221403.1719458030396280283.davem@davemloft.net>
References: <CA+mtBx9inCEq7PS3h02tSThsMLBVv5OUrusDkMg7d-OOvmqdiQ@mail.gmail.com>
	<CAPFHKzc-z4LUkxO+nSB=az25ynr=m5KaudQHYNhYi=VtRafEkw@mail.gmail.com>
	<CA+mtBx-ZW3jVzaXicGi5okS5egMkfi8-SaDX_ewy-k5zRONfmg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jonathon.reinhart@gmail.com, sunil.kovvuri@gmail.com,
	netdev@vger.kernel.org
To: therbert@google.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:41067 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751832AbbBXDOF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Feb 2015 22:14:05 -0500
In-Reply-To: <CA+mtBx-ZW3jVzaXicGi5okS5egMkfi8-SaDX_ewy-k5zRONfmg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tom Herbert <therbert@google.com>
Date: Fri, 20 Feb 2015 15:05:11 -0800

>> Note that this argument is different from RSS where we're dealing with
>> actual hardware queues, so the driver of course has a say in the
>> configuration.
>
> Assuming that all queues are equal and we have a standard way to
> influence the indirection table, even RSS configuration really isn't
> driver specific configuration. We just need to know how many queues
> are available.

Agreed.

If drivers start doing this, fine, but they must do it with a common
piece of infrastructure that each and every driver can (easily) plug
into and make use of.

Even better would be something that was so generic that the driver's
don't actualy implement any part of it other than responding to what
the generic networking core asks it to do.
