From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Support registering a bunch of drivers
Date: Mon, 09 Jul 2012 00:11:14 -0700 (PDT)
Message-ID: <20120709.001114.1511546237738881062.davem@davemloft.net>
References: <20120704154434.GZ19422@elara.bln.innominate.local>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chohnstaedt@innominate.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53568 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751729Ab2GIHLP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jul 2012 03:11:15 -0400
In-Reply-To: <20120704154434.GZ19422@elara.bln.innominate.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Hohnstaedt <chohnstaedt@innominate.com>
Date: Wed, 4 Jul 2012 17:44:34 +0200

> If registering of one of them fails, all already registered drivers
> of this module will be unregistered.
> 
> Use the new register/unregister functions in all drivers
> registering more than one driver.
> 
> amd.c, realtek.c: Simplify: directly return registration result.
> 
> Tested with broadcom.c
> All others compile-tested.
> 
> Signed-off-by: Christian Hohnstaedt <chohnstaedt@innominate.com>

Applied, thanks.
